classdef SDILoggingWarning < handle





properties ( Access = 'private' )
mdl;
dlg;
bd;
listener;
end 


methods 


function this = SDILoggingWarning( mdl )
mlock;
this.mdl = mdl;
end 


function show( this )
dialog = DAStudio.ToolRoot.getOpenDialogs.find(  ...
'dialogTag', [ 'sdi_logging_', this.mdl ] );
if isempty( dialog )
this.dlg = DAStudio.Dialog( this );
else 
this.dlg = dialog;
end 

this.bd = get_param( this.mdl, 'Object' );
this.listener = Simulink.listener( this.bd, 'CloseEvent',  ...
@( hSrc, ev )SDILoggingWarning.closeGUI( this.mdl ) );
end 


function dlgstruct = getDialogSchema( this, ~ )
[ titleStr, msgStr, helpArgs ] =  ...
SDILoggingWarning.getTitleAndMessage( this.mdl );
item1.Type = 'text';
str = msgStr;
item1.Name = str;
item1.WordWrap = true;
item1.MinimumSize = [ 500, 100 ];




dlgstruct.DialogTitle = titleStr;
dlgstruct.HelpMethod = 'helpview';
dlgstruct.HelpArgs =  ...
{ [ docroot, '/toolbox/simulink/helptargets.map' ], helpArgs };
dlgstruct.Items = { item1 };
dlgstruct.StandaloneButtonSet = { 'OK', 'Help' };
dlgstruct.DialogTag = [ 'sdi_', this.mdl ];
dlgstruct.IsScrollable = false;
dlgstruct.DialogTag = [ 'sdi_logging_', this.mdl ];
end 
end 


methods ( Static = true )


function closeGUI( mdl )
dialog = DAStudio.ToolRoot.getOpenDialogs.find(  ...
'dialogTag', [ 'sdi_logging_', mdl ] );
if ~isempty( dialog )
dialog.delete;
end 
end 


function [ titleStr, msgStr, helpArgs ] = getTitleAndMessage( mdl )
msgStr = DAStudio.message( 'Simulink:Logging:OpenRecordNoData', mdl );
titleStr = DAStudio.message( 'Simulink:Logging:OpenRecordNoDataDlgTitle' );
helpArgs = 'sdi_stream_data';
end 

end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpfi5IZG.p.
% Please follow local copyright laws when handling this file.

