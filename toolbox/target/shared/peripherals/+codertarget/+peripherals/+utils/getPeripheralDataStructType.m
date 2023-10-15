function peripheralDataStructType = getPeripheralDataStructType( peripheralType )

arguments
    peripheralType char{ mustBeNonempty };
end

peripheralDataStructType = message( 'codertarget:peripherals:PeripheralDataStructType', peripheralType ).getString(  );
end

