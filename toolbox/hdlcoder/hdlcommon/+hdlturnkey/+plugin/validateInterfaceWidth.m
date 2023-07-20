function validateInterfaceWidth(interfaceID,interfaceWidth,portName)


    if(interfaceWidth>65535)
        error(message('hdlcommon:workflow:VectorPortBitWidthLargerThan65535Bits',...
        interfaceID,interfaceWidth,portName));
    end
end