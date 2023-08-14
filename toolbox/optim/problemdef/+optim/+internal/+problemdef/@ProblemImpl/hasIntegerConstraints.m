function tf=hasIntegerConstraints(prob,problemStruct)




    if~isempty(problemStruct)
        tf=~isempty(problemStruct.intcon);
    else


        tf=false;
        vars=prob.Variables;
        varNames=fieldnames(vars);
        for k=1:numel(varNames)
            if strcmp(vars.(varNames{k}).Type,'integer')
                tf=true;
                return;
            end
        end
    end

end