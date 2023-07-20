classdef Constants




    properties(GetAccess=public,Constant=true)
        DefaultScanTimeout=2
        MinScanTimeout=0
        MaxScanTimeout=10485

        AdvertisingIntervalUnit=0.625/1000
        MinSlaveConnectionInterval=hex2dec('0006')
        MaxSlaveConnectionInterval=hex2dec('0C80')
        NoSpecificSlaveConnectionInterval=hex2dec('FFFF')
        SlaveConnectionIntervalUnit=1.25/1000

        SupportedReadModesReadOnly="latest"
        SupportedReadModesNotifyOnly=["oldest","latest"]

        WriteTypes=["WithResponse","WithoutResponse"]
        WritePrecisions=["uint8","uint16","uint32","uint64"]

        ClientCharacteristicConfigurationUUID="2902"
    end
end