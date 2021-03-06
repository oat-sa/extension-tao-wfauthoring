<?php
use oat\tao\helpers\Template;
?>
<?php if(get_data('error')):?>

	<div class="main-container">
		<div class="ui-state-error ui-corner-all" style="padding:5px;">
			<?php if(get_data('extension')=='taoDelivery'){
				echo __('Please select a delivery before authoring it');
			}else{//==wfEngine
				echo __('Please select a process before authoring it');
			}?>
			<br/>
			<?=get_data('errorMessage')?>
		</div>
		<br />
		<span class="ui-widget ui-state-default ui-corner-all" style="padding:5px;">
			<?php if(get_data('extension')=='taoDelivery'):?>
				<a href="#" onclick="helpers.selectTabByName('manage_deliveries');"><?=__('Back')?></a>
			<?php else://==wfEngine?>
				<a href="#" onclick="helpers.selectTabByName('manage_process');"><?=__('Back')?></a>
			<?php endif;?>
		</span>
	</div>

<?php else:?>
	<style type="text/css">
		/*need to be loaded fast*/
		#accordion_container_1 {float:left;height:100%;width:15%;padding:0px;}
		#accordion_container_2 {float:left;height:100%;width:25%;}
		#processAuthoring_loading{position:absolute; width:99%; height:99%; z-index:1000; background-color:#FFFFFF;}
		#processAuthoring_loading_message{position:relative; top:45%; left:45%; width:150px;}
	</style>
	<link rel="stylesheet" type="text/css" href="<?=Template::css('process_authoring_tool.css', 'wfAuthoring')?>" />

	<div id="processAuthoring_loading">
		<div id="processAuthoring_loading_message">
			<img src="<?=ROOT_URL?>/tao/views/img/ajax-loader.gif" alt="loading" />
		</div>
	</div>

	<script type="text/javascript">
		//constants:
		RDFS_LABEL = "<?=tao_helpers_Uri::encode(RDFS_LABEL)?>";
		PROPERTY_CONNECTORS_TYPE = "<?=tao_helpers_Uri::encode(PROPERTY_CONNECTORS_TYPE)?>";
		INSTANCE_TYPEOFCONNECTORS_SEQUENCE = "<?=tao_helpers_Uri::encode(INSTANCE_TYPEOFCONNECTORS_SEQUENCE)?>";
		INSTANCE_TYPEOFCONNECTORS_CONDITIONAL = "<?=tao_helpers_Uri::encode(INSTANCE_TYPEOFCONNECTORS_CONDITIONAL)?>";
		INSTANCE_TYPEOFCONNECTORS_PARALLEL = "<?=tao_helpers_Uri::encode(INSTANCE_TYPEOFCONNECTORS_PARALLEL)?>";
		INSTANCE_TYPEOFCONNECTORS_JOIN = "<?=tao_helpers_Uri::encode(INSTANCE_TYPEOFCONNECTORS_JOIN)?>";

		//unbind events:
		$(document).off('*.wfAuthoring');

		//init values:
		var processUri = "<?=get_data("processUri")?>";
        var authoringControllerPath = '<?=ROOT_URL?>wfAuthoring/ProcessAuthoring/';
        var img_url = "<?=ROOT_URL?>wfAuthoring/views/img/authoring/";
	</script>

	<!--<script type="text/javascript" src="https://getfirebug.com/firebug-lite.js"></script>-->
	<script type="text/javascript" src="<?=Template::js('authoring/util.js', 'wfAuthoring')?>"></script>
	<!--<script type="text/javascript" src="<?=BASE_WWW.'js/authoring/'?>authoringConfig.js"></script>-->
	<script type="text/javascript" src="<?=Template::js('gateway/ProcessAuthoring.js', 'wfEngine')?>"></script>
	<script type="text/javascript" src="<?=Template::js('authoring/activity.tree.js', 'wfAuthoring')?>"></script>
	<script type="text/javascript" src="<?=Template::js('authoring/arrows.js', 'wfAuthoring')?>"></script>
	<script type="text/javascript" src="<?=Template::js('authoring/activityDiagram.js', 'wfAuthoring')?>"></script>
	<script type="text/javascript" src="<?=Template::js('authoring/modeController.js', 'wfAuthoring')?>"></script>
	<script type="text/javascript" src="<?=Template::js('authoring/modeInitial.js', 'wfAuthoring')?>"></script>
	<script type="text/javascript" src="<?=Template::js('authoring/modeActivityLabel.js', 'wfAuthoring')?>"></script>
	<script type="text/javascript" src="<?=Template::js('authoring/modeActivityMenu.js', 'wfAuthoring')?>"></script>
	<script type="text/javascript" src="<?=Template::js('authoring/modeArrowLink.js', 'wfAuthoring')?>"></script>
	<script type="text/javascript" src="<?=Template::js('authoring/modeActivityMove.js', 'wfAuthoring')?>"></script>
	<script type="text/javascript" src="<?=Template::js('authoring/modeConnectorMove.js', 'wfAuthoring')?>"></script>
	<script type="text/javascript" src="<?=Template::js('authoring/modeArrowEdit.js', 'wfAuthoring')?>"></script><!---->

	<script type="text/javascript">
	function processProperty(){
		helpers._load("#process_form",
			authoringControllerPath+"editProcessProperty",
			{processUri: processUri}
		);
	}

	function loadSectionTree(section){
	//section in [serviceDefinition, formalParameter, role]

		$.ajax({
			url: authoringControllerPath+'getSectionTrees',
			type: "POST",
			data: {section: section},
			dataType: 'html',
			success: function(response){
				$('#'+section+'_tree').html(response);
			}
		});
	}

	function loadActivityTree(){
		$.ajax({
			url: authoringControllerPath+'getActivityTree',
			type: "POST",
			data: {section: "activity"},
			dataType: 'html',
			success: function(response){
				$('#activity_tree').html(response);
			}
		});
	}
require(['jquery', 'i18n', 'helpers'], function($, __, helpers){

        window.__ = __;
        window.helpers = helpers;
 


		$("#accordion1").accordion({
			fillSpace: true,
			autoHeight: false,
			collapsible: false,
			active: 0,
			icons: { 'header': 'ui-icon-circle-triangle-s', 'headerSelected': 'ui-icon-circle-triangle-e' }
		});

		$("#accordion2").accordion({
			fillSpace: true,
			autoHeight: false,
			collapsible: false,
			icons: { 'header': 'ui-icon-circle-triangle-s', 'headerSelected': 'ui-icon-circle-triangle-e' }
		});

                //resizeable containers:
                var $centerPanel = $('#process_center_panel');
                $("#accordion_container_1").resizable({
                        'handles':'e',
                        'helper': "ui-resizable-helper",
                        'stop': function(event, ui){
                                var sizeDiff = ui.size.width - ui.originalSize.width;
                                $centerPanel.width($centerPanel.width() - sizeDiff);
                        }
                });
                $("#accordion_container_2").resizable({
                        'handles':'w',
                        'helper': "ui-resizable-helper",
                        'stop': function(event, ui){
                                var sizeDiff = ui.size.width - ui.originalSize.width;
                                $centerPanel.width($centerPanel.width() - sizeDiff);
                                $(this).css('left',0);
                        }
                });

		//load activity tree:
		loadActivityTree();

		//load the trees:
		loadSectionTree("serviceDefinition");//use get_value instead to get the uriResource of the service definition class and make
		loadSectionTree("formalParameter");
		loadSectionTree("role");
		loadSectionTree("variable");

		//load process property form
		processProperty();

    ActivityDiagramClass.canvas = "#process_diagram_container";
    ActivityDiagramClass.localNameSpace = "<?=tao_helpers_Uri::encode(common_ext_NamespaceManager::singleton()->getLocalNamespace()->getUri())?>";

    //draw diagram:
    $(ActivityDiagramClass.canvas).scroll(function(){
        // TODO: set a more cross-browser way to retrieve scroll left and top values:
        ActivityDiagramClass.scrollLeft = this.scrollLeft;
        ActivityDiagramClass.scrollTop = this.scrollTop;
    });

    //bind events to activity diagram:
    $.getScript('<?=Template::js('authoring/ActivityDiagramEventBinding.js', 'wfAuthoring')?>', function(){
            $(ActivityDiagramClass.canvas).click(function(evt){
                    if (evt.target == evt.currentTarget) {
                            ModeController.setMode('ModeInitial');
                    }
            });

            //load activity diagram:
            try{
                    ActivityDiagramClass.loadDiagram();
            }
            catch(err){
                    console.log('feed&draw diagram exception', err);
            }
    });
});

	</script>

	<div class="main-container" style="display:none;"></div>
	<div id="authoring-container" class="ui-helper-reset">

		<div id="accordion_container_1">
			<div id="accordion1" style="font-size:0.8em;">
				<h3><a href="#"><?=__('Service Definition')?></a></h3>
				<div>
					<div id="serviceDefinition_tree"/>
					<div id="serviceDefinition_form"/>
				</div>
				<h3><a href="#"><?=__('Formal Parameter')?></a></h3>
				<div>
					<div id="formalParameter_tree"/>
					<div id="formalParameter_form"/>
				</div>
				<h3><a href="#"><?=__('Role')?></a></h3>
				<div>
					<div id="role_tree"/>
					<div id="role_form"/>
				</div>
				<h3><a href="#"><?=__('Process Variables')?></a></h3>
				<div>
					<div id="variable_tree"/>
					<div id="variable_form"/>
				</div>
			</div>
		</div><!--end accordion -->

		<div id="process_center_panel">
			<div id="process_diagram_feedback" class="ui-corner-top"></div>
			<div id="process_diagram_container" class="ui-corner-bottom">
				<div id="status"/>
			</div>
		</div>

		<div id="accordion_container_2">
			<div id="accordion2" style="font-size:0.8em;">
				<h3><a href="#"><?=__('Activity Editor')?></a></h3>
				<div>
					<div id="activity_tree"/>
					<div id="activity_form"/>
				</div>
				<h3><a href="#"><?=__('Process Property')?></a></h3>
				<div>
					<div id="process_form"><?=__('loading...')?></div>
				</div>
				<?php if(get_data('extension')=='taoDelivery'):?>
				<h3><a href="#"><?=__('Compilation')?></a></h3>
				<div>
					<div id="compile_info"><?=__('loading...')?></div>
					<div id="compile_form"></div>
				</div>
				<?php endif;?>
			</div><!--end accordion -->
		</div><!--end accordion_container_2 -->

		<div style="clear:both"/>
	</div><!--end authoring-container -->

<?php endif;?>

<?php
Template::inc('footer.tpl');
?>
