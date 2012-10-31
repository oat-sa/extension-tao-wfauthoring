<?php

/**
 *  Process Controler provide actions to edit a process
 * 
 * @author Bertrand Chevrier, <taosupport@tudor.lu>
 * @package wfEngine
 * @subpackage actions
 * @license GPLv2  http://www.opensource.org/licenses/gpl-2.0.php
 */
class wfAuthoring_actions_Process extends tao_actions_TaoModule {
	
	
	protected $authoringService = null;
	
	/**
	 * constructor: initialize the service and the default data
	 * @return Groups
	 */
	public function __construct()
	{
		
		parent::__construct();
		
		//the service is initialized by default
		$this->service = new wfAuthoring_models_classes_wfAuthoringService();
		$this->authoringService = new wfAuthoring_models_classes_ProcessService();
		$this->defaultData();
		
		Session::setAttribute('currentSection', 'process');
	}
	
/*
 * conveniance methods
 */
	
	/**
	 * get the main class
	 * @return core_kernel_classes_Classes
	 */
	protected function getRootClass()
	{
		return $this->service->getProcessClass();
	}
	
/*
 * controller actions
 */
	
	/**
	 * Overriden to remove URIS set in other section 
	 * and to prevent a wrong action state based on the resource.
	 * @return void
	 */
	public function index()
	{
		
		$this->removeSessionAttribute('uri');
		$this->removeSessionAttribute('classUri');
		
		parent::index();
	}
	
	
	/**
	 * Edit a group instance
	 * @return void
	 */
	public function editProcess()
	{
		$clazz = $this->getCurrentClass();
		$process = $this->getCurrentInstance();
		
		$excludedProperties = array(
			PROPERTY_PROCESS_VARIABLES,
			PROPERTY_PROCESS_ACTIVITIES,
			PROPERTY_PROCESS_ROOT_ACTIVITIES
		);
		
		$formContainer = new tao_actions_form_Instance($clazz, $process, array('excludedProperties' => $excludedProperties));
		$myForm = $formContainer->getForm();
		
		//@TODO : put into the process definition service:
		$aclModes = array(
			tao_helpers_Uri::encode(INSTANCE_ACL_ROLE) => 'Role',
			tao_helpers_Uri::encode(INSTANCE_ACL_ROLE_RESTRICTED_USER) => 'User'
			);
		$myForm->getElement(tao_helpers_Uri::encode(PROPERTY_PROCESS_INIT_ACL_MODE))->setOptions($aclModes);
		if($myForm->isSubmited()){
			if($myForm->isValid()){
				
				$process = $this->service->bindProperties($process, $myForm->getValues());
				
				$this->setSessionAttribute("showNodeUri", tao_helpers_Uri::encode($process->uriResource));
				$this->setData('message', __('Process saved'));
				$this->setData('reload', true);
			}
		}
		
		$this->setData('uri', tao_helpers_Uri::encode($process->uriResource));
		$this->setData('classUri', tao_helpers_Uri::encode($clazz->uriResource));
		$this->setData('formTitle', 'Process properties');
		$this->setData('myForm', $myForm->render());
		$this->setView('form_process.tpl');
	}

	/**
	 * Delete a group or a group class
	 * @return void
	 */
	public function delete()
	{
		if(!tao_helpers_Request::isAjax()){
			throw new Exception("wrong request mode");
		}
		
		$deleted = false;
		if($this->getRequestParameter('uri')){
			$deleted = $this->authoringService->deleteProcess($this->getCurrentInstance());
		}
		// else{
			// $deleted = $this->service->deleteGroupClass($this->getCurrentClass());
		// }//no subclass available, therefore no delete action associated
		
		echo json_encode(array('deleted'	=> $deleted));
	}
	
	public function authoring()
	{
		$this->setData('error', false);
		try{
			//get process instance to be authored
			$processDefinition = $this->getCurrentInstance();
			$this->setData('processUri', tao_helpers_Uri::encode($processDefinition->uriResource));
		}
		catch(Exception $e){
			$this->setData('error', true);
			$this->setData('errorMessage', $e);
		}
		$this->setView('authoring/process_authoring_tool.tpl');
	}
	
	public function editProcessClass()
	{
		$this->removeSessionAttribute('uri');
		parent::index();
	}
	
	/**
	 * Duplicate a process instance
	 *
	 * @access public
     * @author CRP Henri Tudor - TAO Team - {@link http://www.tao.lu}
	 * @return void
	 */
	public function cloneProcess()
	{
		if(!tao_helpers_Request::isAjax()){
			throw new Exception("wrong request mode");
		}
		
		$clone = $this->service->cloneProcess($this->getCurrentInstance(), $this->getCurrentClass());
		if(!is_null($clone)){
			echo json_encode(array(
				'label'	=> $clone->getLabel(),
				'uri' 	=> tao_helpers_Uri::encode($clone->uriResource)
			));
		}
	}
	
}
?>