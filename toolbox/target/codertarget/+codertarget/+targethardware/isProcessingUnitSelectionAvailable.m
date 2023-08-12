function out = isProcessingUnitSelectionAvailable( hObj )





hwInfo = codertarget.targethardware.getTargetHardware( hObj );
out = codertarget.data.isValidParameter( hObj, 'ESB.ProcessingUnit' ) &&  ...
hwInfo.hasProcessingUnit;
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpKogafs.p.
% Please follow local copyright laws when handling this file.

