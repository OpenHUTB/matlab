function sendOpenConfigSetMessage(target)
    if(strcmp(target,'CovTopOff'))

        virtualChannel=sprintf('CoverageTopOff/LaunchConfigSetUI');
        payloadStruct=struct('VirtualChannel',virtualChannel,'Payload',0);
        message.publish('/stm/messaging',payloadStruct);
    end
end