function modified=modelModified(name,oldTs)






    if bdIsLoaded(name)
        modified='true';
        newTs=get_param(name,'ModifiedTimeStamp');
        if isequal(oldTs,-1)||isequal(oldTs,newTs)
            modified='false';
        end
    else
        modified='false';
    end

end
