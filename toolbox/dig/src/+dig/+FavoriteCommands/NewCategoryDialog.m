

classdef NewCategoryDialog
properties ( Access = private )
Manager
end 

properties ( Constant )
Tag = 'NewCategoryDialog';
end 

methods 
function this = NewCategoryDialog( manager )
R36
manager dig.FavoriteCommands.Manager;
end 

this.Manager = manager;
end 

function dlg = getDialogSchema( ~, ~ )
edit.Tag = 'label';
edit.Type = 'edit';
edit.Name = DAStudio.message( 'simulink_ui:studio:resources:simulinkFavoriteCategoryDialogEditName' );
edit.ToolTip = DAStudio.message( 'simulink_ui:studio:resources:simulinkFavoriteCategoryDialogEditToolTip' );
edit.ObjectMethod = 'onEditChanged';
edit.MethodArgs = { '%dialog', '%value' };
edit.ArgDataTypes = { 'handle', 'mxArray' };
edit.RespondsToTextChanged = true;

okButton.Type = 'pushbutton';
okButton.Name = DAStudio.message( 'simulink_ui:studio:resources:simulinkFavoriteCommandDialogOK' );
okButton.RowSpan = [ 1, 1 ];
okButton.ColSpan = [ 2, 2 ];
okButton.Tag = 'okButton';
okButton.Enabled = false;
okButton.ObjectMethod = 'onOK';
okButton.MethodArgs = { '%dialog' };
okButton.ArgDataTypes = { 'handle' };



cancelButton.Type = 'pushbutton';
cancelButton.Name = DAStudio.message( 'simulink_ui:studio:resources:simulinkFavoriteCommandDialogCancel' );
cancelButton.RowSpan = [ 1, 1 ];
cancelButton.ColSpan = [ 3, 3 ];
cancelButton.Tag = 'cancelButton';
cancelButton.ObjectMethod = 'onCancel';
cancelButton.MethodArgs = { '%dialog' };
cancelButton.ArgDataTypes = { 'handle' };

buttonContainer.Name = 'buttonContainer';
buttonContainer.Tag = 'buttonContainer';
buttonContainer.Type = 'panel';
buttonContainer.LayoutGrid = [ 1, 3 ];
buttonContainer.ColStretch = [ 1, 0, 0 ];
buttonContainer.Items = { okButton, cancelButton };

dlg.DialogTag = dig.FavoriteCommands.NewCategoryDialog.Tag;
dlg.DialogTitle = DAStudio.message( 'simulink_ui:studio:resources:simulinkFavoriteCategoryDialogTitle' );
dlg.Items = { edit };
dlg.StandaloneButtonSet = buttonContainer;
dlg.Sticky = true;

dlg.OpenCallback = @dig.FavoriteCommands.NewCategoryDialog.onOpen;
end 

function onEditChanged( ~, dlg, value )
dlg.setEnabled( 'okButton', ~isempty( strtrim( value ) ) );
end 

function onOK( this, dlg )
label = dlg.getWidgetValue( 'label' );
this.Manager.addCategory( label );
dlg.delete;
end 

function onCancel( ~, dlg )
dlg.delete;
end 
end 

methods ( Static )
function onOpen( dlg )
dlg.setFocus( 'label' );
dlg.setEnabled( 'okButton', false );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpDiW7R5.p.
% Please follow local copyright laws when handling this file.

