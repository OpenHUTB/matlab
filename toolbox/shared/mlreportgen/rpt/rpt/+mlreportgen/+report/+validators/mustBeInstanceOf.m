function mustBeInstanceOf(class,value)
    if~condition(class,value)
        throw(createValidatorException(...
        'mlreportgen:report:validators:mustBeInstanceOf',class));
    end
end

function is=condition(class,value)
    is=(isnumeric(value)&&isempty(value))||...
    (isa(value,class)&&numel(value)==1);
end
