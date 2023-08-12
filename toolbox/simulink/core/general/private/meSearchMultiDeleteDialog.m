function doDelete = meSearchMultiDeleteDialog










message_str = DAStudio.message( 'Simulink:utility:FindVarsMESearchMultiDeleteMsg' );
title_str = DAStudio.message( 'Simulink:utility:FindVarsMESearchMultiDeleteTitle' );
cancel_str = DAStudio.message( 'Simulink:utility:CancelButton' );
ok_str = DAStudio.message( 'Simulink:utility:OKButton' );

response = questdlg( message_str, title_str, ok_str, cancel_str, cancel_str );

doDelete = strcmp( response, ok_str );

% Decoded using De-pcode utility v1.2 from file /tmp/tmprykIO8.p.
% Please follow local copyright laws when handling this file.

