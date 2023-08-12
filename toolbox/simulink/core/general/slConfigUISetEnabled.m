function slConfigUISetEnabled( hDlg, hSrc, prop, val )%#ok













hParent = hSrc;
while ~isempty( hParent.getParent ) && isa( hParent.getParent, 'Simulink.BaseConfig' )
hParent = hParent.getParent;
end 

hParent.setPropEnabled( prop, val );


% Decoded using De-pcode utility v1.2 from file /tmp/tmp39WI90.p.
% Please follow local copyright laws when handling this file.

