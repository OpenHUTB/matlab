function result = isXilinxIP( obj )


result = false;
if obj.isIPWorkflow && ~obj.isBoardEmpty && obj.isBoardLoaded
vendor = obj.hTurnkey.hBoard.FPGAVendor;
result = strcmpi( vendor, 'Xilinx' );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpz1QDZq.p.
% Please follow local copyright laws when handling this file.

