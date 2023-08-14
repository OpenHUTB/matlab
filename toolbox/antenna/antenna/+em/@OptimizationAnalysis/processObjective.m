function objectiveValue=processObjective(obj,inputObjVal,OptimizationType,Conflict,DisplayValue)





    if Conflict||isempty(inputObjVal)
        objectiveValue=1e6;
    else

        if strcmpi(OptimizationType,'max')
            objectiveValue=-inputObjVal;
        else
            objectiveValue=inputObjVal;
        end




















    end

end