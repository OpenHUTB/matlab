function slConfigUISetVal( hDlg, hSrc, prop, val )












hParent = hSrc;
while ~isempty( hParent.getParent ) && isa( hParent.getParent, 'Simulink.BaseConfig' )
hParent = hParent.getParent;
end 

hParent.set_param( prop, val );

if ~isempty( hDlg ) && isa( hDlg, 'DAStudio.Dialog' )
hDlg.getDialogSource.enableApplyButton( true );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmp41ST5q.p.
% Please follow local copyright laws when handling this file.

