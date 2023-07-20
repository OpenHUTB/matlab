function sendMSGToUI(value,msg,replaceLastLine)




    virtualChannel=sprintf('Update/Report/Generation/Status');
    payload=struct('msg',msg,'value',value,'replaceLastLine',replaceLastLine);
    payloadStruct=struct('VirtualChannel',virtualChannel,'Payload',payload);
    message.publish('/stm/messaging',payloadStruct);
end