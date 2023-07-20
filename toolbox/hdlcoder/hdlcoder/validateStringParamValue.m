function[v,returnValue]=validateStringParamValue(value,param,defaultValue)





    if nargin<3
        defaultValue='';
    end

    if~isempty(value)&&~isa(value,'char')
        v=hdlvalidatestruct(1,...
        message('hdlcoder:validate:nonstringvalue',param));
        returnValue=defaultValue;
    else
        v=hdlvalidatestruct(0,...
        message('hdlcoder:validate:nomsg'));
        returnValue=value;
    end

end

