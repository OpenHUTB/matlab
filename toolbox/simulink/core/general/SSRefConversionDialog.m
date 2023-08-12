






classdef SSRefConversionDialog < handle

methods ( Static, Access = 'public' )





function dialogHandle = createDialog( blockHandle, subsysDlgHandle )

static_data = SSRefConversionDialog.getStaticDialogData(  );
if ~isempty( static_data.Handles )
index = SSRefConversionDialog.getDialogDataIndex(  ...
static_data, blockHandle );
if ~isempty( index )
dialogHandle = static_data.Handles( index ).DialogHandle;




if ~isempty( subsysDlgHandle )
obj = dialogHandle.getSource(  );
obj.m_subsys_dlg_handle = subsysDlgHandle;
end 
return ;
end 
end 


obj = SSRefConversionDialog( blockHandle, subsysDlgHandle );
dialogHandle = DAStudio.Dialog( obj );
SSRefConversionDialog.resetDialogSize( dialogHandle );


static_data.Handles( end  + 1 ).BlockHandle = blockHandle;
static_data.Handles( end  ).DialogHandle = dialogHandle;
end 
end 

methods ( Access = 'public' )


function dlg = getDialogSchema( this )

name = strrep( get_param( this.m_block_handle, 'Name' ), newline, ' ' );
dlg.DialogTitle = [ this.m_dialog_title, ' : ', name ];
dlg.DialogTag = this.m_dialog_tag;


top_desc_text.Name = this.m_top_description;
top_desc_text.Tag = this.m_desc_text_tag;
top_desc_text.Type = 'text';
top_desc_text.WordWrap = true;



file_name_edit_box.Name = this.m_file_name_prompt;
file_name_edit_box.Tag = this.m_file_name_tag;
file_name_edit_box.Type = 'edit';
file_name_edit_box.Value = this.getDefaultNameForSSRefModel( name );
file_name_edit_box.RowSpan = [ 1, 1 ];



browse_button.Name = this.m_browse_button_text;
browse_button.Tag = this.m_browse_button_tag;
browse_button.Type = 'pushbutton';
browse_button.RowSpan = [ 1, 1 ];
browse_button.ColSpan = [ 2, 2 ];
browse_button.ObjectMethod = 'browseButtonCallback';
browse_button.MethodArgs = { '%dialog', this.m_file_name_tag };
browse_button.ArgDataTypes = { 'handle', 'string' };



test_harness_option.Name = this.m_move_test_harness_prompt;
test_harness_option.Tag = this.m_test_harness_checkbox_tag;
test_harness_option.Type = 'checkbox';
test_harness_option.RowSpan = [ 2, 2 ];
test_harness_option.ColSpan = [ 1, 2 ];

[ enabled, tooltip ] = this.isTestHarnessOptionEnabled(  );
test_harness_option.Enabled = enabled;
test_harness_option.Value = enabled;
if ~enabled
test_harness_option.ToolTip = tooltip;
end 



file_browse_panel.Tag = this.m_file_browse_panel_tag;
file_browse_panel.Type = 'panel';
file_browse_panel.LayoutGrid = [ 2, 2 ];
file_browse_panel.Items = { file_name_edit_box,  ...
browse_button, test_harness_option };



convert_message_text.Name = this.m_converting_message;
convert_message_text.Tag = this.m_message_text_tag;
convert_message_text.Type = 'text';
convert_message_text.RowSpan = [ 2, 2 ];
convert_message_text.Visible = false;
convert_message_text.WordWrap = true;



convert_group.Tag = this.m_convert_group_tag;
convert_group.Type = 'group';
convert_group.LayoutGrid = [ 2, 1 ];
convert_group.Items = { file_browse_panel, convert_message_text };



convert_button.Name = this.m_convert_button_prompt;
convert_button.Type = 'pushbutton';
convert_button.Tag = this.m_convert_button_tag;
convert_button.ColSpan = [ 1, 1 ];
convert_button.RowSpan = [ 1, 1 ];
convert_button.ObjectMethod = 'convertButtonCallback';
convert_button.MethodArgs = { '%dialog', this.m_convert_button_tag };
convert_button.ArgDataTypes = { 'handle', 'string' };

cancel_button.Name = this.m_cancel_button_prompt;
cancel_button.Type = 'pushbutton';
cancel_button.Tag = this.m_cancel_button_tag;
cancel_button.ColSpan = [ 2, 2 ];
cancel_button.RowSpan = [ 1, 1 ];
cancel_button.ObjectMethod = 'cancelButtonCallback';
cancel_button.MethodArgs = { '%dialog', this.m_cancel_button_tag };
cancel_button.ArgDataTypes = { 'handle', 'string' };

button_panel.Type = 'panel';
button_panel.Items = { convert_button, cancel_button };
button_panel.Tag = this.m_button_panel_tag;
button_panel.LayoutGrid = [ 1, 2 ];









browser_selected_file_text.Name = '';
browser_selected_file_text.Type = 'text';
browser_selected_file_text.Tag = this.m_browser_selected_file_tag;
browser_selected_file_text.Visible = false;

browser_selected_dir_text.Name = '';
browser_selected_dir_text.Type = 'text';
browser_selected_dir_text.Tag = this.m_browser_selected_dir_tag;
browser_selected_dir_text.Visible = false;


dlg.Items = { top_desc_text, convert_group,  ...
browser_selected_file_text, browser_selected_dir_text };
dlg.StandaloneButtonSet = button_panel;

dlg.CloseCallback = 'onDialogCloseCallback';
dlg.CloseArgs = { this, '%dialog' };
end 

end 

methods ( Access = 'public' )


function browseButtonCallback( this, dlg, tagToBeFilled )


try 
defaultFileName = dlg.getWidgetValue( tagToBeFilled );
browser = SubsystemReferenceBrowser( false, defaultFileName, dlg,  ...
this.m_browser_selected_file_tag, this.m_browser_selected_dir_tag );

browser.browse( dlg, tagToBeFilled, false );
catch E
throwAsCaller( E )
end 
end 




function overWriteFile = getUserInputToOverWriteFile( this, filePath )
error_message = DAStudio.message(  ...
'Simulink:SubsystemReference:FileExists', filePath );
yes = message( 'Simulink:editor:DialogYes' ).getString;
no = message( 'Simulink:editor:DialogNo' ).getString;
user_choice = questdlg( error_message, this.m_dialog_title, yes, no, yes );

overWriteFile = false;
switch user_choice
case yes
overWriteFile = true;
end 
end 




function result = checkForParentBlockDiagram( this, ssName )
parent_bd = bdroot( this.m_block_handle );
parent_bd_name = get_param( parent_bd, 'Name' );

if ~strcmp( parent_bd_name, ssName )
result = true;
return ;
end 


block_path = getfullname( this.m_block_handle );
error_message = DAStudio.message(  ...
'Simulink:SubsystemReference:CannotPointToParentBD', block_path, ssName );
errordlg( error_message, this.m_dialog_title, 'modal' );
result = false;
end 




function [ goAhead, fullFilePath ] = canCreateFile( this, dlg )

edit_box_value = dlg.getWidgetValue( this.m_file_name_tag );

browser_selected_file_name = dlg.getWidgetValue( this.m_browser_selected_file_tag );
[ ~, browser_selected_ss_name, ~ ] = fileparts( browser_selected_file_name );



if ( ~this.checkForParentBlockDiagram( edit_box_value ) )
goAhead = false;
fullFilePath = '';
return ;
end 

dir_path = dlg.getWidgetValue( this.m_browser_selected_dir_tag );
if isempty( dir_path )
dir_path = [ pwd, filesep ];
end 




goAhead = true;
if ( ~strcmp( edit_box_value, browser_selected_ss_name ) )

file_format = get_param( 0, 'ModelFileFormat' );
full_file_name = [ dir_path, edit_box_value, '.', file_format ];
if isfile( full_file_name )
goAhead = this.getUserInputToOverWriteFile( full_file_name );
end 
fullFilePath = full_file_name;
return ;
end 


fullFilePath = [ dir_path, browser_selected_file_name ];
end 




function convertButtonCallback( this, dlg, ~ )

this.enableDisableActionsOnDialog( dlg, false );

err_dlg_opts = 'modal';
new_ss_name = dlg.getWidgetValue( this.m_file_name_tag );
if ( ~isvarname( new_ss_name ) )
errordlg( DAStudio.message( 'Simulink:SubsystemReference:SRNameMustBeValid',  ...
new_ss_name ), this.m_dialog_title, err_dlg_opts );
this.enableDisableActionsOnDialog( dlg, true );
return ;
end 

[ can_create, full_file_path ] = this.canCreateFile( dlg );
if ( ~can_create )
this.enableDisableActionsOnDialog( dlg, true );
return ;
end 



this.m_old_dlg_position = dlg.Position(  );
this.showConversionMessageOnDialog( dlg );

ssref_converter = SubsystemReferenceConverter( this.m_block_handle,  ...
full_file_path, true );
[ status, message ] = ssref_converter.convertSubsystem(  );

if ( ~status )
cleanupAndErrorHandling( this, dlg, false, message );
return ;
end 

if ( status && dlg.getWidgetValue( this.m_test_harness_checkbox_tag ) )
this.showMovingTHMessageOnDialog( dlg );
[ ~, message ] = this.moveTestHarnessFromSSRefBlockToSubsystemBD(  ...
ssref_converter.getSubsystemBDHandle(  ) );
end 

cleanupAndErrorHandling( this, dlg, true, message );

end 

function cleanupAndErrorHandling( this, dlg, createdSubsystemFile, message )
this.hideMessageOnDialog( dlg );

dlg.Position = this.m_old_dlg_position;

if ( ~isempty( message ) )
message = slprivate( 'removeHyperLinksFromMessage', message );
err_dlg = errordlg( message, this.m_dialog_title, 'modal' );
waitfor( err_dlg );
end 

this.enableDisableActionsOnDialog( dlg, true );
if ( createdSubsystemFile )
dlg.clearWidgetDirtyFlag( this.m_file_name_tag );
this.showReferenceModelParamOnSubsystemDialog(  );
dlg.delete(  );
end 
end 

function [ status, errorMessage ] = moveTestHarnessFromSSRefBlockToSubsystemBD( this, subsystemBDHandle )
try 

orig_val = slsvTestingHook( 'IgnoreOwnerTypeCheckDuringClone', 1 );
cleanup_obj = onCleanup( @(  )slsvTestingHook(  ...
'IgnoreOwnerTypeCheckDuringClone', orig_val ) );

harness_list = sltest.harness.find( this.m_block_handle );
bd_name = get_param( subsystemBDHandle, 'Name' );
for ii = 1:length( harness_list )
if ( harness_list( ii ).synchronizationMode == 2 )


sltest.harness.set( this.m_block_handle, harness_list( ii ).name,  ...
'SynchronizationMode', 'SyncOnOpen' )
end 
sltest.harness.clone( this.m_block_handle,  ...
harness_list( ii ).name, 'DestinationOwner', bd_name );
sltest.harness.delete( this.m_block_handle, harness_list( ii ).name );
end 
save_system( subsystemBDHandle );
status = true;
errorMessage = '';
catch exp
new_exp = MSLException( [  ], message(  ...
'Simulink:SubsystemReference:ErrorDuringTransferOfTH' ) );
new_exp = new_exp.addCause( exp );
status = false;
errorMessage = getExceptionMsgReport( new_exp );
end 
end 



function enableDisableActionsOnDialog( this, dlg, enablestate )
dlg.setEnabled( this.m_file_browse_panel_tag, enablestate );
dlg.setEnabled( this.m_button_panel_tag, enablestate );
end 



function showConversionMessageOnDialog( this, dlg )
dlg.setVisible( this.m_message_text_tag, true );





current_position = dlg.Position;
if ( current_position( 4 ) < 250 )
current_position( 4 ) = 250;
end 
dlg.Position = current_position;
end 



function showMovingTHMessageOnDialog( this, dlg )
dlg.setWidgetValue( this.m_message_text_tag,  ...
this.m_moving_test_harness_message );
end 



function hideMessageOnDialog( this, dlg )
dlg.setVisible( this.m_message_text_tag, false );
end 



function showReferenceModelParamOnSubsystemDialog( this )

if isempty( this.m_subsys_dlg_handle ) ||  ...
~ishandle( this.m_subsys_dlg_handle )
return ;
end 

this.m_subsys_dlg_handle.setVisible( 'convert_to_srblock_panel_tag', false );
this.m_subsys_dlg_handle.setVisible( 'browse_open_panel_tag', true );
this.m_subsys_dlg_handle.apply(  );
end 



function doCleanup( this, dlg )
dlg.setVisible( this.m_message_text_tag, false );
dlg.setEnabled( this.m_file_name_tag, true );
dlg.setEnabled( this.m_button_panel_tag, true );
end 



function cancelButtonCallback( ~, dlg, ~ )
dlg.delete(  );
end 



function onDialogCloseCallback( this, dialogHandle )
static_data = SSRefConversionDialog.getStaticDialogData(  );
index = find( [ static_data.Handles.DialogHandle ] == dialogHandle );
if ~isempty( index )
static_data.Handles( index ) = [  ];
end 

if ~isempty( this.m_subsys_dlg_handle )
this.m_subsys_dlg_handle.refresh;
end 
end 



function onBlockRemoveCallback( this, ~, event, ~, ~ )
if isequal( event.BlockHandle, this.m_block_handle )
dlgHandle = this.getDialogHandle( this.m_block_handle );
if ishandle( dlgHandle )
dlgHandle.delete(  );
end 
end 
end 



function onModelCloseCallback( this, ~, event, ~, ~ )
if is_simulink_handle( this.m_block_handle )
if isequal( event.Source.Name, get_param( bdroot( this.m_block_handle ), 'Name' ) )
dlgHandle = this.getDialogHandle( this.m_block_handle );
if ishandle( dlgHandle )
dlgHandle.delete(  );
end 
end 
end 
end 



function defaultName = getDefaultNameForSSRefModel( ~, blockName )
defaultName = blockName;
expressionToReplace = { '\W', '_+', '_$' };
replaceWith = { '_', '_', '' };
for i = 1:numel( expressionToReplace )
defaultName = regexprep( defaultName,  ...
expressionToReplace{ i }, replaceWith{ i }, 'emptymatch' );
end 
if ( isempty( regexpi( defaultName, '^[a-z]', 'match' ) ) )
defaultName = [ 's', defaultName ];
end 
end 



function [ result, tooltip ] = isTestHarnessOptionEnabled( this )
result = false;
tooltip = '';
if ( this.isTestHarnessInstalled(  ) )
if ~isempty( sltest.harness.find( this.m_block_handle ) )
result = true;
return ;
end 
tooltip = DAStudio.message( 'Simulink:SubsystemReference:NoAssociatedTestHarness' );
return ;
end 
tooltip = DAStudio.message( 'Simulink:SubsystemReference:InstallTestHarness' );
end 

end 

methods ( Access = 'private', Static )


function obj = SSRefConversionDialog( blockHandle, subsystemDlgHandle )
obj.m_block_handle = blockHandle;
obj.m_subsys_dlg_handle = subsystemDlgHandle;

bdHandle = bdroot( blockHandle );
bdCosObj = get_param( bdHandle, 'InternalObject' );

obj.m_block_remove_listener = addlistener( bdCosObj,  ...
'SLGraphicalEvent::REMOVE_BLOCK_MODEL_EVENT',  ...
@( src, evnt )obj.onBlockRemoveCallback( src, evnt, '', '' ) );

obj.m_model_close_listener = addlistener( bdCosObj,  ...
'SLGraphicalEvent::DESTROY_MODEL_EVENT',  ...
@( src, evnt )obj.onModelCloseCallback( src, evnt, '', '' ) );
end 



function result = isTestHarnessInstalled(  )
product_list = matlabshared.supportpkg.internal.ssi.util.getInstalledProducts( 'productnames' );
result = any( strcmpi( 'Simulink Test', product_list ) );
end 





function resetDialogSize( dialogHandle )
position = dialogHandle.Position;
if ( position( 3 ) < 410 )
position( 3 ) = 410;
end 
dialogHandle.Position = position;
end 




function dialogData = getStaticDialogData(  )
persistent static_dialog_data;
if isempty( static_dialog_data )
static_dialog_data = SRDialogData;
end 
dialogData = static_dialog_data;
end 



function dlgHandle = getDialogHandle( blockHandle )
static_dlg_data = SSRefConversionDialog.getStaticDialogData(  );
if ~isempty( static_dlg_data.Handles )
index = SSRefConversionDialog.getDialogDataIndex(  ...
static_dlg_data, blockHandle );
if ~isempty( index )
dlgHandle = static_dlg_data.Handles( index ).DialogHandle;
return ;
end 
end 
dlgHandle = [  ];
end 





function index = getDialogDataIndex( dialogData, blockHandle )
if ~isempty( dialogData.Handles )
index = find( [ dialogData.Handles.BlockHandle ] == blockHandle );
else 
index = [  ];
end 
end 

end 

properties ( Access = 'private' )
m_block_handle;
m_subsys_dlg_handle;

m_block_remove_listener;
m_model_close_listener;
m_old_dlg_position;
end 

properties ( Constant, Access = 'private' )
m_dialog_title = DAStudio.message( 'Simulink:SubsystemReference:ConvertToSRDlgTitleText' );
m_top_description = DAStudio.message( 'Simulink:SubsystemReference:ConvertToSRHelpText' );
m_browse_button_text = DAStudio.message( 'Simulink:protectedModel:btnBrowse' );
m_file_name_prompt = DAStudio.message( 'Simulink:SubsystemReference:SRParameterPrompt' );
m_convert_button_prompt = DAStudio.message( 'Simulink:SubsystemReference:SRConvert' );
m_cancel_button_prompt = DAStudio.message( 'Simulink:SubsystemReference:SRCancel' );
m_converting_message = DAStudio.message( 'Simulink:SubsystemReference:ConvertingText' );
m_move_test_harness_prompt = DAStudio.message( 'Simulink:SubsystemReference:MoveTestHarnessPrompt' );
m_moving_test_harness_message = DAStudio.message( 'Simulink:SubsystemReference:MovingTestHarnessMessage' );


m_dialog_tag = 'SRDialogTag';
m_desc_text_tag = 'SRDescText';
m_file_browse_panel_tag = 'SRFileBrowsePanel';
m_file_name_tag = 'SRFileNameEdit';
m_browse_button_tag = 'SRConversionBrowseButtonTag';
m_convert_group_tag = 'SRConvertGroup';
m_convert_button_tag = 'SRConvertButton';
m_cancel_button_tag = 'SRCancelButton';
m_button_panel_tag = 'SRButtonPanel';
m_message_text_tag = 'SRConversionMessageText';
m_browser_selected_file_tag = 'SRBrowserSelectedFileTag';
m_browser_selected_dir_tag = 'SRBrowserSelectedDirTag';
m_test_harness_checkbox_tag = 'SRTestHarnessCheckBoxTag';
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp1Ix845.p.
% Please follow local copyright laws when handling this file.

