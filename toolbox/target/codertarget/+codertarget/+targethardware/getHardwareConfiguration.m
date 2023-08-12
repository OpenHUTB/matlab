function out = getHardwareConfiguration( hObj )





hardware = codertarget.targethardware.getTargetHardware( hObj );
if ~isempty( hardware ) && hardware.hasProcessingUnit(  ) &&  ...
codertarget.targethardware.isProcessingUnitSelectionAvailable( hObj )
out = codertarget.targethardware.getProcessingUnitInfo( hObj );
else 
out = hardware;
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmptTq4c4.p.
% Please follow local copyright laws when handling this file.

