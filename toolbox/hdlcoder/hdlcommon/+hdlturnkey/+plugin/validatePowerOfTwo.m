function validatePowerOfTwo(value,propertyName,example)




    valuePow2=2^nextpow2(value);
    if value~=valuePow2
        error(message('hdlcommon:plugin:ValueNonPowerOfTwo',...
        num2str(value),propertyName,example));
    end

end