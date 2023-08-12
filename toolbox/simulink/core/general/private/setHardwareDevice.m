function setHardwareDevice( hObj, mode, device )




if strcmp( mode, 'Production' )
platform = 'Prod';
else 
platform = mode;
end 

configset.internal.util.HardwareSettingsHelper.setHardwareDevice( hObj, platform, device );



% Decoded using De-pcode utility v1.2 from file /tmp/tmpECTnQV.p.
% Please follow local copyright laws when handling this file.

