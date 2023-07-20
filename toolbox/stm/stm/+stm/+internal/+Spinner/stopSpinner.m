


function stopSpinner
    payloadStruct=struct('VirtualChannel','tests/Finished','Payload',...
    struct('Error','none'));
    message.publish('/stm/messaging',payloadStruct);
end
