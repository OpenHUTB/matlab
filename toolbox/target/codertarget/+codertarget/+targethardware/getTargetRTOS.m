function targetRTOS = getTargetRTOS( hObj )





if ischar( hObj )
hObj = getActiveConfigSet( hObj );
end 

targetRTOS = 'Baremetal';
data = codertarget.data.getData( hObj.getConfigSet(  ) );
if ~isempty( data ) && isfield( data, 'RTOS' )
targetRTOS = codertarget.data.getParameterValue( hObj, 'RTOS' );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpsBvhGD.p.
% Please follow local copyright laws when handling this file.

