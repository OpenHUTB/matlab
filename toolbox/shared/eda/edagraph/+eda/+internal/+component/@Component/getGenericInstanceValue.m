function value=getGenericInstanceValue(this,generic)





    if isfield(generic,'instance_Value')
        tmpValue=generic.instance_Value;
        if strcmpi(tmpValue,'''0''')||strcmpi(tmpValue,'''1''')
            value=tmpValue;
        elseif isa(tmpValue,'char')
            value=eval(tmpValue);
        else
            value=this.getGenericInstanceValue(tmpValue);
        end
    else
        value=generic.default_Value;
    end
end

