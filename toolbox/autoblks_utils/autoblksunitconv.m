function DestinationData=autoblksunitconv(SourceData,SourceDataUnits,DestinationDataUnits)






    Info=Simulink.UnitUtils.getConversionInfo('',SourceDataUnits,DestinationDataUnits);
    if~Info.isInverted
        DestinationData=SourceData*Info.scaling+Info.offset;
    else
        DestinationData=Info.scaling/SourceData;
    end
