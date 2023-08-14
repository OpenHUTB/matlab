
function refreshTestTree()

    payloadStruct=struct('VirtualChannel','Refresh/Test/Tree','Payload',struct());
    message.publish('/stm/messaging',payloadStruct);
end

