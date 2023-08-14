function ok=VerifyAsCurrentValue(parameter,value)





    ok=true;
    format=parameter.Format;
    if~isempty(format)
        type=parameter.Type;
        if~isempty(type)


            if~isa(format,'serdes.internal.ibisami.ami.format.Value')
                ok=parameter.validateValue(value);
            end
        end
    end

