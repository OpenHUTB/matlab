function errorIfUnavailable( hCS )





if isempty( codertarget.targethardware.getTargetHardware( hCS ) )
hw = codertarget.data.getParameterValue( hCS, 'TargetHardware' );
DAStudio.error( 'codertarget:build:SupportPackageNotInstalled', hw, hw, hw );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpTfEy99.p.
% Please follow local copyright laws when handling this file.

