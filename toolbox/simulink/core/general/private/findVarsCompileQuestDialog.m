function doCompile = findVarsCompileQuestDialog( models )









mdlStrs = '';
cr = sprintf( '\n' );
if iscell( models )
for u = 1:length( models )
mdlStrs = [ mdlStrs, cr, ' - ', models{ u } ];%#ok
end 
elseif ischar( models )
mdlStrs = [ mdlStrs, cr, ' - ', models ];
end 


message_str = DAStudio.message( 'Simulink:utility:FindVarsMECompileQuestMsg', mdlStrs );
title_str = DAStudio.message( 'Simulink:utility:FindVarsMECompileQuestTitle' );
cancel_str = DAStudio.message( 'Simulink:utility:CancelButton' );
ok_str = DAStudio.message( 'Simulink:utility:OKButton' );

response = questdlg( message_str, title_str, ok_str, cancel_str, cancel_str );

doCompile = strcmp( response, ok_str );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpwjtsGP.p.
% Please follow local copyright laws when handling this file.

