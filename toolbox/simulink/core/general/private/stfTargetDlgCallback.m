function stfTargetDlgCallback( hObj, hDlg, propName, val, callback, prompt, uiType )




model = hObj.getModel;%#ok<NASGU>
hConfigSet = hObj.getConfigSet;%#ok<NASGU>
try 
loc_eval( hObj, hDlg, propName, val, callback );
catch 
warnmsg = ( [ 'The code generation option "', prompt, '" has some invalid settings',  ...
sprintf( '\n' ),  ...
'in its callback field. Please see Simulink Coder User''s Guide' ...
, sprintf( '\n' ),  ...
'as reference to set it up correctly' ] );


sldiagviewer.reportWarning( warnmsg, 'Component', 'RTW', 'Category', 'SYSTLC' );
end 
if ~isempty( hDlg ) && isa( hDlg, 'DAStudio.Dialog' ) && ~isequal( uiType, 'pushbutton' )
hDlg.enableApplyButton( true, false );
end 

function loc_eval( hSrc, hDlg, currentVar, currentVal, evalstr )
model = hSrc.getModel;
hConfigSet = hSrc.getConfigSet;
eval( evalstr );


% Decoded using De-pcode utility v1.2 from file /tmp/tmpdRhGP4.p.
% Please follow local copyright laws when handling this file.

