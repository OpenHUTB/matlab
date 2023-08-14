function validateFPGAPinCount(interfaceID,FPGAPin,portName,interfaceWidth)


    if length(FPGAPin)~=interfaceWidth
        error(message('hdlcommon:workflow:FPGAOutPortWidthBound',interfaceID,...
        length(FPGAPin),portName,interfaceWidth));
    end
end