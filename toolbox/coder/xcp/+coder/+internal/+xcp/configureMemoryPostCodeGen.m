function configureMemoryPostCodeGen(modelName,buildInfo,isHostBased)





    cs=getActiveConfigSet(modelName);
    transportIdx=get_param(cs,'ExtModeTransport');
    transport=Simulink.ExtMode.Transports.getExtModeTransport(cs,transportIdx);

    numBitsPerChar=get_param(modelName,'TargetBitPerChar');
    addressGranularity=numBitsPerChar/8;
    targetConfiguration=coder.internal.xcp.XCPTargetConfiguration(transport,addressGranularity);

    configurator=coder.internal.xcp.XCPMemoryConfigurator(...
    modelName,...
    targetConfiguration,...
    UseInternalDefines=true);

    configurator.NumBytesPerMultiWordChunk=coder.internal.xcp.getBytesPerMultiWordChunk(modelName);
    configurator.SizeOfTargetDouble=8;

    if slprivate('onoff',cs.get_param('ExtModeAutomaticAllocSize'))
        loggingBufferSize=[];
        maxDuration=cs.get_param('ExtModeMaxTrigDuration');
    else
        loggingBufferSize=cs.get_param('ExtModeStaticAllocSize');



        if isHostBased
            maxDuration=1000;
        else



            maxDuration=10;
        end
    end
    configurator.addDefines(...
    buildInfo,...
    maxDuration,...
    sizeOfLoggingBuffer=loggingBufferSize,...
    printSummary=slprivate('onoff',cs.get_param('RTWVerbose')));

end
