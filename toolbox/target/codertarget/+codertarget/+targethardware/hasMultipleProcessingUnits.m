function out = hasMultipleProcessingUnits( hCS )




out = false;
hw = codertarget.targethardware.getTargetHardware( hCS );
if ~isempty( hw ) && hw.hasProcessingUnit(  )
out = hw.hasProcessingUnit;
end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmptqVSQR.p.
% Please follow local copyright laws when handling this file.

