







function inFiTYpes=convertFromJava(types)



    inFiTYpes=[];
    for jj=1:length(types)
        type=types(jj);
        varName=char(type(1));
        typeStr=char(type(2));
        if~isempty(strtrim(typeStr))
            try

                numericType=eval(typeStr);
            catch

                numericType=numerictype(typeStr);
            end
        else
            numericType=[];
        end

        tmpVars=strsplit(varName,'.');
        if 1==length(tmpVars)
            inFiTYpes.(varName)=numericType;
        else
            eval(['inFiTYpes.',varName,'= numericType;']);%#ok<EVLDOT> 
        end
    end
end
