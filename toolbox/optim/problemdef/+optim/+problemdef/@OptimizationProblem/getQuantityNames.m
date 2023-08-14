function[varNames,objNames,conNames]=getQuantityNames(p)








    varNames=string(fieldnames(p.Variables));


    if isstruct(p.Objective)
        objNames=string(fieldnames(p.Objective));
    else
        objNames="Objective";
    end


    if isstruct(p.Constraints)&&~isempty(p.Constraints)
        conNames=string(fieldnames(p.Constraints));
    else
        conNames="Constraints";
    end

end