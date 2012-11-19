<?if(get_data('message')):?>
	<div id="info-box" class="ui-widget-header ui-corner-all auto-slide">
		<span><?=get_data('message')?></span>
	</div>
<?endif?>
<div class="main-container">
	<table id="user-list"></table>
	<div id="user-list-pager"></div>
	<br />
	<span class="ui-state-default ui-corner-all">
		<a href="#" onclick="helpers.selectTabByName('add_user');">
			<img src="<?=TAOBASE_WWW?>img/add.png" alt="add" /> <?=__('Add a user')?>
		</a>
	</span>
	<br />
	<br />
</div>
<script type="text/javascript">
require(['require', 'jquery', 'grid/tao.grid'], function(req, $) {
	function editUser(uri){
		index = helpers.getTabIndexByName('edit_user');
		if(index && uri){
			editUrl = "<?=_url('edit', 'Users')?>" + '?uri=' + uri;
			uiBootstrap.tabs.tabs('url', index, editUrl);
			uiBootstrap.tabs.tabs('enable', index);
			helpers.selectTabByName('edit_user');
		}
	}
	function removeUser(uri){
		if(confirm("<?=__('Please confirm user deletion')?>")){
			$.ajax({
				url: "<?=_url('delete', 'Users')?>",
				type: "POST",
				data: {uri:uri},
				dataType: 'json',
				success: function(response){
					helpers.createMessage(response.message);
					if(response.deleted){
						$("#user-list").trigger('reloadGrid');
					}
				}
			});
		}
	}
	$(function(){
		var myGrid = $("#user-list").jqGrid({
			url: "<?=_url('data', 'Users')?>",
			datatype: "json",
			colNames:[ __('Login'), __('Name'), __('Email'), __('Data Language'), __('Interface Language'), __('Role(s)'),__('Actions')],
			colModel:[
				{name:'login',index:'login'},
				{name:'name',index:'name'},
				{name:'email',index:'email', width: '200'},
				{name:'deflg',index:'deflg', align:"center", width: '100'},
				{name:'uilg',index:'uilg', align:"center", width: '100'},
				{name:'role',index:'role', align:"center"},
				{name:'actions',index:'actions', align:"center", sortable: false}
			],
			rowNum:20,
			height:300,
			width: (parseInt($("#user-list").width()) - 2),
			pager: '#user-list-pager',
			sortname: 'login',
			viewrecords: false,
			sortorder: "asc",
			caption: __("Workflow Users"),
			gridComplete: function(){
				$.each(myGrid.getDataIDs(), function(index, elt){
					if(myGrid.getRowData(elt).role != 'TaoManager'){
						myGrid.setRowData(elt, {
							actions: "<a id='user_editor_"+elt+"' href='#' class='user_editor nd' ><img class='icon' src='<?=BASE_WWW?>img/pencil.png' alt='<?=__('Edit user')?>' /><?=__('Edit')?></a> | " +
							"<a id='user_deletor_"+elt+"' href='#' class='user_deletor nd' ><img class='icon' src='<?=BASE_WWW?>img/delete.png' alt='<?=__('Delete user')?>' /><?=__('Delete')?></a>"
						});
					}
				});
				$(".user_editor").click(function(){
					editUser(this.id.replace('user_editor_', ''));
				});
				$(".user_deletor").click(function(){
					removeUser(this.id.replace('user_deletor_', ''));
				});

				$(window).unbind('resize').bind('resize', function(){
					myGrid.jqGrid('setGridWidth', (parseInt($("#user-list").width()) - 2));
				});
			}
		});
		myGrid.navGrid('#user-list-pager',{edit:false, add:false, del:false});

		helpers._autoFx();
	});
});
</script>

<?include(BASE_PATH.'/views/templates/footer.tpl');?>