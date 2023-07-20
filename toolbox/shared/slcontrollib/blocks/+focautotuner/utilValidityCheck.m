function isValid=utilValidityCheck(param,checkPerformed,errMsg,varargin)














    isValid=true;
    switch checkPerformed

    case 'Positive'
        if any(param<=0)
            isValid=false;
        end

    case 'NonNegative'
        if all(param<0)
            isValid=false;
        end

    case 'Size'
        expectedSize=varargin{1};
        L=length(param);
        if~any(L==expectedSize)
            isValid=false;
        end

    case 'Finite'
        if~all(isfinite(param))
            isValid=false;
        end

    case 'Real'
        if~all(isreal(param))
            isValid=false;
        end

    case 'Value'
        paramValueRange=varargin{1};
        if~all(((paramValueRange(1)<param)&(paramValueRange(2)>=param)))
            isValid=false;
        end

    case 'Sample Time'
        check=~all((param==-1)|(param>0));
        if check
            isValid=false;
        end

    case 'Zero'
        if any(param==0)
            isValid=false;
        end
    end


    if~isValid
        error(errMsg)
    end