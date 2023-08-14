function reportGenerationIsDone(obj)





    stm.internal.setReportGenerationStatus(0,0);
    virtualChannel=sprintf('Report/Generation/DONE');
    payloadStruct=struct('VirtualChannel',virtualChannel,'Payload',0);
    message.publish('/stm/messaging',payloadStruct);
end