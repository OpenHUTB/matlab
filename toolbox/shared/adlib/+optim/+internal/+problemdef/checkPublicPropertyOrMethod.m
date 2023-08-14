function checkPublicPropertyOrMethod(obj,fieldName,validProps)












    if~any(strcmp(fieldName,validProps))
        if~ismethod(obj,fieldName)
            error(message('MATLAB:noSuchMethodOrField',fieldName,class(obj)));
        end
    end
