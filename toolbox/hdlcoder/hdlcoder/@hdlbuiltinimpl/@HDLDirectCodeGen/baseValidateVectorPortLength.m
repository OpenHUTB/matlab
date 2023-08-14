function v=baseValidateVectorPortLength(this,port,allowedLength,err_msg)%#ok<INUSL>






















    v=hdlvalidatestruct;

    if~isscalar(port)
        warning(message('hdlcoder:validate:vectorport'));
    else

        if isscalar(allowedLength)
            [minLength,maxLength]=deal(allowedLength);
        elseif prod(size(allowedLength)==2)
            minLength=allowedLength(1);
            maxLength=allowedLength(2);
        else
            warning(message('hdlcoder:validate:inputallowedlength'));
            return;
        end


        portDim=max(max(hdlsignalvector(port)),1);

        if(portDim>maxLength||portDim<minLength)
            v=hdlvalidatestruct(1,err_msg);
        end

    end


