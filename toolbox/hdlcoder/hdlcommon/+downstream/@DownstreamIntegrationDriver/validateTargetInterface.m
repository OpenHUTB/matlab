function validateCell = validateTargetInterface( obj )


obj.validateBoardLoaded;
if obj.isInterfaceTableNeeded
validateCell = obj.hTurnkey.hTable.validateInterfaceTable;
else 
validateCell = {  };
end 

if ( obj.isIPCoreGen )

validateCellNoAXI = obj.hTurnkey.hD.hIP.adjustAXI4SlaveEnable;
validateCell = [ validateCell, validateCellNoAXI ];
obj.hTurnkey.hD.hIP.adjustIDWidthValue;
validateCellIDValue = obj.hTurnkey.hD.hIP.adjustIDWidthBoxGUI;
validateCell = [ validateCell, validateCellIDValue ];
obj.hTurnkey.hD.hIP.adjustAXI4SlaveEnableGUI;
end 




if obj.cmdDisplay

downstream.tool.displayValidateCell( validateCell );
end 

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpxncNgL.p.
% Please follow local copyright laws when handling this file.

