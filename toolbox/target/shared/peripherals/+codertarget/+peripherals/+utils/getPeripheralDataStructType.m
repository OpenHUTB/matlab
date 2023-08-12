function peripheralDataStructType = getPeripheralDataStructType( peripheralType )




R36
peripheralType char{ mustBeNonempty };
end 

peripheralDataStructType = message( 'codertarget:peripherals:PeripheralDataStructType', peripheralType ).getString(  );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmp594jAN.p.
% Please follow local copyright laws when handling this file.

