function createEthernetPacketBusObj( dataLength )

arguments
    dataLength( 1, 1 ){ mustBeInteger, mustBeGreaterThan( dataLength, 13 ), mustBeLessThan( dataLength, 1515 ) };
end

busObjExists = false;

if isempty( bdroot )

    if evalin( 'base', "exist('Ethernet_Packet', 'var')" )
        EthPacketBusObj = evalin( 'base', "Ethernet_Packet" );
        busObjExists = true;
    end
else
    if Simulink.data.existsInGlobal( bdroot, "Ethernet_Packet" )
        EthPacketBusObj = Simulink.data.evalinGlobal( bdroot, "Ethernet_Packet" );
        busObjExists = true;
    end
end

if busObjExists

    assert( isa( EthPacketBusObj, 'Simulink.Bus' ), getString( message( 'slrealtime:Ethernet:NotBusObj' ) ) );
    assert( numel( EthPacketBusObj.Elements ) == 2, getString( message( 'slrealtime:Ethernet:InvalidBusObj' ) ) );
    assert( EthPacketBusObj.Elements( 1 ).Name == "Data" && EthPacketBusObj.Elements( 2 ).Name == "Length", getString( message( 'slrealtime:Ethernet:InvalidBusObj' ) ) );
    assert( EthPacketBusObj.Elements( 1 ).DataType == "uint8" && EthPacketBusObj.Elements( 2 ).DataType == "uint16", getString( message( 'slrealtime:Ethernet:InvalidBusObj' ) ) );
    assert( numel( EthPacketBusObj.Elements( 1 ).Dimensions ) == 2 &&  ...
        EthPacketBusObj.Elements( 1 ).Dimensions( 2 ) == 1 &&  ...
        EthPacketBusObj.Elements( 2 ).Dimensions == 1,  ...
        getString( message( 'slrealtime:Ethernet:InvalidBusObj' ) ) );


    currDataLength = EthPacketBusObj.Elements( 1 ).Dimensions( 1 );
    if currDataLength < dataLength
        s = sprintf( "Ethernet_Packet.Elements(1).Dimensions(1) = %i;", dataLength );
        if isempty( bdroot )
            evalin( 'base', s );
        else
            Simulink.data.evalinGlobal( bdroot, s );
        end
    end

else

    clear elems;

    i = 1;
    elems( i ) = Simulink.BusElement;
    elems( i ).Name = 'Data';
    elems( i ).Dimensions = [ dataLength, 1 ];
    elems( i ).DimensionsMode = 'Fixed';
    elems( i ).DataType = 'uint8';
    elems( i ).SampleTime =  - 1;
    elems( i ).Complexity = 'real';
    elems( i ).Min = [  ];
    elems( i ).Max = [  ];
    elems( i ).DocUnits = '';
    elems( i ).Description = '';

    i = i + 1;
    elems( i ) = Simulink.BusElement;
    elems( i ).Name = 'Length';
    elems( i ).Dimensions = 1;
    elems( i ).DimensionsMode = 'Fixed';
    elems( i ).DataType = 'uint16';
    elems( i ).SampleTime =  - 1;
    elems( i ).Complexity = 'real';
    elems( i ).Min = [  ];
    elems( i ).Max = [  ];
    elems( i ).DocUnits = '';
    elems( i ).Description = '';

    Ethernet_Packet = Simulink.Bus;
    Ethernet_Packet.HeaderFile = '';
    Ethernet_Packet.Description = '';
    Ethernet_Packet.DataScope = 'Auto';
    Ethernet_Packet.Alignment =  - 1;
    Ethernet_Packet.Elements = elems;
    clear elems;

    if isempty( bdroot )
        assignin( 'base', 'Ethernet_Packet', Ethernet_Packet );
    else
        Simulink.data.assigninGlobal( bdroot, 'Ethernet_Packet', Ethernet_Packet );
    end
end
