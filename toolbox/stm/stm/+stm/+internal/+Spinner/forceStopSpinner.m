
function forceStopSpinner()

    payloadStruct=struct('VirtualChannel','Force/StopSpinner','Payload',struct());
    message.publish('/stm/messaging',payloadStruct);
end

