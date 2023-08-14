function mustBeInstanceOfMultiClass(classes,value)






    if~condition(classes,value)
        classStr=strjoin(classes,"', '");
        throw(createValidatorException(...
        'mlreportgen:report:validators:mustBeInstanceOfMultiClass',classStr));
    end
end

function is=condition(classes,value)
    is=isnumeric(value)&&isempty(value);

    n=length(classes);
    while~is&&(n>0)
        is=isa(value,classes{n});
        n=n-1;
    end

end