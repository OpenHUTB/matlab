function[v,returnValue]=validateParamValue(value,paramInfo)






    paramType=paramInfo.ImplParamType;
    param=paramInfo.ImplParamName;
    legalValues=paramInfo.AllValues;
    defaultValue=paramInfo.DefaultValue;

    switch lower(paramType)
    case 'enum'
        [v,returnValue]=validateEnumParamValue(value,param,legalValues,defaultValue);
    case 'string'
        [v,returnValue]=validateStringParamValue(value,param,defaultValue);
    case 'posint'
        [v,returnValue]=validatePosIntParamValue(value,param,defaultValue);
    case 'int'
        [v,returnValue]=validateIntParamValue(value,param,defaultValue);
    case 'mxarray'

        v=hdlvalidatestruct(0,...
        message('hdlcoder:validate:nomsg'));
        returnValue=value;
    otherwise

        v=hdlvalidatestruct(0,...
        message('hdlcoder:validate:nomsg'));
        returnValue=value;
    end

end

function[v,returnValue]=validatePosIntParamValue(value,param,defaultValue)

    v=hdlvalidatestruct(0,...
    message('hdlcoder:validate:nomsg'));
    returnValue=value;

    if~isempty(value)
        if~isnumeric(value)
            v=hdlvalidatestruct(1,message('hdlcoder:validate:ValNonnumeric',param));
            returnValue=defaultValue;
        elseif any(double(value)<0)
            v=hdlvalidatestruct(1,message('hdlcoder:validate:ValNonpositive',param));
            returnValue=defaultValue;
        elseif any(double(value)~=floor(double(value)))
            v=hdlvalidatestruct(1,message('hdlcoder:validate:ValNoninteger',param));
            returnValue=defaultValue;
        end
    end

end

function[v,returnValue]=validateIntParamValue(value,param,defaultValue)

    v=hdlvalidatestruct(0,...
    message('hdlcoder:validate:nomsg'));
    returnValue=value;

    if~isempty(value)
        if~isnumeric(value)
            v=hdlvalidatestruct(1,message('hdlcoder:validate:ValNonnumeric',param));
            returnValue=defaultValue;
        elseif any(double(value)~=floor(double(value)))
            v=hdlvalidatestruct(1,message('hdlcoder:validate:ValNoninteger',param));
            returnValue=defaultValue;
        end
    end

end

