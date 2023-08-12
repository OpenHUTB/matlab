function ret = slConfigUIGetVal( hDlg, hSrc, prop )%#ok












hParent = hSrc;
while ~isempty( hParent.getParent ) && isa( hParent.getParent, 'Simulink.BaseConfig' )
hParent = hParent.getParent;
end 

ret = hParent.get_param( prop );
% Decoded using De-pcode utility v1.2 from file /tmp/tmpSLo6eE.p.
% Please follow local copyright laws when handling this file.

