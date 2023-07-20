classdef Constants


    properties(Constant)
        MacvideoDiscoveryTimeoutMin=100
        MacvideoDiscoveryTimeoutMax=120000
        MacvideoDiscoveryTimeoutStep=100

        GigePacketAckTimeoutMin=500
        GigePacketAckTimeoutMax=120000
        GigePacketAckTimeoutStep=100

        GigeHeartbeatTimeoutMin=500
        GigeHeartbeatTimeoutMax=120000
        GigeHeartbeatTimeoutStep=100

        GigeCommandRetriesMin=0
        GigeCommandRetriesMax=10
        GigeCommandRetriesStep=1

        MacvideoDiscoveryTimeoutFactoryValue=100
        GigeCommandRetriesFactoryValue=3
        GigePacketAckTimeoutFactoryValue=500
        GigeHeartbeatTimeoutFactoryValue=600
        GigeDisableForceIPFactoryValue=false
    end
end