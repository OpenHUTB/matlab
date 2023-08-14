
function validateFPGAPinCount(portValue,portName,portCount,example)

    if length(portValue)~=portCount
        error(message('hdlcommon:workflow:FPGAOutPortWidthBound',portName,...
        length(portValue),portName,portCount));
    end
    for i=1:length(portValue)
        hdlturnkey.plugin.validateIntegerRangeProperty(portValue(i),portName,255,65535,example)
    end
end