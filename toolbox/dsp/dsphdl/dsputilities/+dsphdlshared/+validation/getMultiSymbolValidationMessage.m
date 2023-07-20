function err_msg=getMultiSymbolValidationMessage(port,allowedLength)







    if isscalar(allowedLength)
        err_msg=message('dsp:hdlshared:getMultiSymbolValidationMessage:allowedexactlength',...
        port.name,allowedLength);
    elseif(numel(allowedLength)==2)
        minLength=allowedLength(1);
        maxLength=allowedLength(2);
        err_msg=message('dsp:hdlshared:getMultiSymbolValidationMessage:allowedrangelength',...
        port.name,minLength,maxLength);
    else
        warning(message('dsp:hdlshared:getMultiSymbolValidationMessage:inputallowedlength'));
        err_msg=message('dsp:hdlshared:getMultiSymbolValidationMessage:inputallowedlength');
    end

end

