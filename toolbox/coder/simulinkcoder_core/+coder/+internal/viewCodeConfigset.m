function viewCodeConfigset( ModelName, filepath )








persistent cs;


[ locConfigSetObj, isProtected ] = locLoadMatFile( filepath );
if isempty( locConfigSetObj )
error( message( 'RTW:configSet:configSetUnavailable', ModelName ) );
end 

if isProtected
title = message( 'RTW:report:ProtectedModelConfigSetTitle', ModelName ).getString;
else 
title = message( 'RTW:report:ConfigSetTitle', ModelName ).getString;
end 


if isa( cs, 'Simulink.ConfigSet' ) && isa( cs.getDialogHandle, 'DAStudio.Dialog' ) &&  ...
strcmp( cs.getDialogHandle.getTitle, title )
dlg = cs.getDialogHandle;
dlg.show;
else 

cs = locConfigSetObj;
cs.view;
dlg = cs.getDialogHandle;
if ~isempty( dlg )


dlg.setTitle( title );
end 
end 






function [ ConfigSetObj, isProtected ] = locLoadMatFile( filepath )
ConfigSetObj = [  ];
isProtected = false;

if exist( filepath, 'file' )
info = load( filepath );
if isfield( info, 'infoStructConfigSet' ) && isa( info.infoStructConfigSet, 'Simulink.ConfigSet' )


ConfigSetObj = info.infoStructConfigSet;
ConfigSetObj.readonly = 'on';
elseif isfield( info, 'protectedModelConfigSet' ) && isa( info.protectedModelConfigSet, 'Simulink.ConfigSet' )


ConfigSetObj = info.protectedModelConfigSet;
ConfigSetObj.readonly = 'on';
isProtected = true;
end 
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpvwNg_G.p.
% Please follow local copyright laws when handling this file.

