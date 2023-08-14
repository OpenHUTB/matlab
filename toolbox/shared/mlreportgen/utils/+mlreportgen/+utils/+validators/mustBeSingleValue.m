function mustBeSingleValue(value)
    if~isempty(value)&&~isvector(value)
        throw(createValidatorException('mlreportgen:utils:validators:mustBeSingleValue'));
    end


    if ischar(value)
        s=size(string(value));
    else
        s=size(value);
    end
    if(s(1)~=0)||(s(2)~=0)
        if(s(1)~=1)
            throw(createValidatorException('mlreportgen:utils:validators:mustBeSingleValue'));
        end
    end

    if~ischar(value)
        if numel(value)>1
            throw(createValidatorException('mlreportgen:utils:validators:mustBeSingleValue'));
        end
    end

end
