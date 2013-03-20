<?php
require_once dirname(__FILE__) . '/../../wfEngine/test/wfEngineServiceTest.php';
/*
require_once dirname(__FILE__) . '/../../tao/test/TaoTestRunner.php';
include_once dirname(__FILE__) . '/../includes/raw_start.php';
*/
class ConnectorAuthoringTestCase extends wfEngineServiceTest {
	
	/**
	 * @var wfAuthoring_models_classes_ConnectorService
	 */
	private $service;
	
	/**
	 * tests initialization
	 */
	public function setUp(){
		parent::setUp();
		TaoTestRunner::initTest();
		
		$this->service = wfAuthoring_models_classes_ConnectorService::singleton();
	}

	// wfAuthoring Connector Service not finished yet

	/**
						+---------------+
                  		|  activity 1   |
		                +---------------+
		                        |
		                    +---v---+
		                    |   c   |
		                    +--+-+--+
		                        |
		                +-------v--------+
		                |   activity 2   |
		                +-------+--------+
		                        |
		                    +---v---+
		                    |   c   |
		                    +--+-+--+
		                        |
		                +-------v--------+
		                |  activity 3    |
		                +-------+--------+
		                        |
		                    +---v---+
		                    |   c   |
		                    +--+-+--+
		                        |
		                +-------v--------+
		                |  activity 4    |
		                +----------------+
	 */
	public function testSequential(){
		$process = wfAuthoring_models_classes_ProcessService::singleton()->createProcess('Scripted Process');
	
		$activityAuthoring = wfAuthoring_models_classes_ActivityService::singleton();
		
		$webservice = new core_kernel_classes_Resource('http://www.tao.lu/Ontologies/TAODelivery.rdf#ServiceWebService');
		$activity = array();
		for ($i = 1; $i <= 4; $i++) {
			$activity[$i] = $activityAuthoring->createFromServiceDefinition($process, $webservice, array());
		}
		
		wfAuthoring_models_classes_ProcessService::singleton()->setFirstActivity($process, $activity[1]);
		
		$this->service->createSequential($activity[1], $activity[2]);
		$this->service->createSequential($activity[2], $activity[3]);
		$this->service->createSequential($activity[3], $activity[4]);
		
		$this->runProcess($process, 4);
		
		wfAuthoring_models_classes_ProcessService::singleton()->deleteProcess($process);
	}
	
	/*
	
		             	+---------------+
                		|  activity 1   |
		                +---------------+
		                        |
		                    +---v---+
		                    |  c 1  |
		                    +--+-+--+
		              t        | |       f
		            +----------+ +---------+
		            |                      |
		    +-------v--------+     +-------v--------+
		    |   activity 2   |     |  activity 3    |
		    +-------+--------+     +----------------+
		            |
		            +-----------+
		                        |
		                    +---v---+
		                    |  c 2  |
		                    +--+-+--+
		              t        | |       f
		            +----------+ +---------+
		            |                      |
		    +-------v--------+     +-------v--------+
		    |   activity 4   |     |  activity 5    |
		    +----------------+     +-------+--------+
					              		   |
					                   +---v---+
					                   |   c   |
					                   +--+-+--+
					                       |
					               +-------v--------+
					               |  activity 6    |
					               +----------------+
		*/
			
	public function testConditional() {
		$process = wfAuthoring_models_classes_ProcessService::singleton()->createProcess('Scripted Process');
	
		$activityAuthoring = wfAuthoring_models_classes_ActivityService::singleton();
		
		$webservice = new core_kernel_classes_Resource('http://www.tao.lu/Ontologies/TAODelivery.rdf#ServiceWebService');
		$activity = array();
		for ($i = 1; $i <= 6; $i++) {
			$activity[$i] = $activityAuthoring->createFromServiceDefinition($process, $webservice, array());
		}
		
		wfAuthoring_models_classes_ProcessService::singleton()->setFirstActivity($process, $activity[1]);
		
		$alwaysTrue		= wfAuthoring_models_classes_RuleService::singleton()->createConditionExpressionFromString('2 > 1');
		$alwaysFalse	= wfAuthoring_models_classes_RuleService::singleton()->createConditionExpressionFromString('2 < 1');
		
		$c1 = $this->service->createConditional($activity[1], $alwaysTrue, $activity[2], $activity[3]);
		$c2 = $this->service->createConditional($activity[2], $alwaysFalse, $activity[4], $activity[5]);
		$this->service->createSequential($activity[5], $activity[6]);
		
		$this->runProcess($process, 4);
		
		wfAuthoring_models_classes_ProcessService::singleton()->deleteProcess($process);
		
	}
	
	private function runProcess($processDefinition, $expectedSteps) {
		$user = $this->createUser('timmy');
		$this->changeUser('timmy');
		$processExecutionService = wfEngine_models_classes_ProcessExecutionService::singleton();
		$processInstance = $processExecutionService->createProcessExecution($processDefinition, $processDefinition->getLabel().' instance', '');
		
		$currentActivityExecutions = $processExecutionService->getCurrentActivityExecutions($processInstance);
		$steps = 0;
		while (count($currentActivityExecutions) > 0) {
			$steps++;
			$current = array_shift($currentActivityExecutions);
			$transitionResult = $processExecutionService->performTransition($processInstance, $current);
			if ($transitionResult !== false) {
				foreach ($transitionResult as $executed) {
					$this->assertTrue($executed->hasType(new core_kernel_classes_Class(CLASS_ACTIVITY_EXECUTION)));
				}
			}
			$currentActivityExecutions = $processExecutionService->getCurrentActivityExecutions($processInstance);
			foreach ($currentActivityExecutions as $key => $exec) {
				$status = wfEngine_models_classes_ActivityExecutionService::singleton()->getStatus($exec);
				if (!is_null($status) && $status->getUri() == INSTANCE_PROCESSSTATUS_FINISHED) {
					unset($currentActivityExecutions[$key]);
				}
			}
		}
		$this->assertEqual($steps, $expectedSteps);
		$processExecutionService->deleteProcessExecution($processInstance);
		$user->delete();
	}
	
	public function tearDown() {
		parent::tearDown();
    }



}
?>