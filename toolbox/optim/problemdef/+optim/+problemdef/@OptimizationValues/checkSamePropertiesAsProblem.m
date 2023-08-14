function checkSamePropertiesAsProblem(obj,p)











    valueQuantities=properties(obj);


    varNames=fieldnames(p.Variables);
    if isstruct(p.Objective)
        objNames=fieldnames(p.Objective);
    else
        objNames={'Objective'};
    end
    if~isempty(p.Constraints)&&isstruct(p.Constraints)
        conNames=fieldnames(p.Constraints);
    else
        conNames={'Constraints'};
    end
    problemQuantities=[varNames;objNames;conNames];



    commonQuantities=intersect(valueQuantities,problemQuantities);
    if numel(commonQuantities)~=numel(valueQuantities)||...
        numel(commonQuantities)~=numel(problemQuantities)
        error(message('optim_problemdef:OptimizationValues:ValuesAndProblemMustHaveSameQuantities'));
    end


    iCheckSameSize(obj,p,"Variables","VariableSize");
    iCheckSameSize(obj,p,"Objective","ObjectiveSize");
    iCheckSameSize(obj,p,"Constraints","ConstraintSize");

end

function iCheckSameSize(obj,p,probQuantityName,SizeProperty)





    varNames=fieldnames(obj.(SizeProperty));


    tmpProbQuantities=p.(probQuantityName);


    for i=1:numel(varNames)


        if isstruct(tmpProbQuantities)&&~isempty(tmpProbQuantities)
            probQuantities=tmpProbQuantities;
        else
            probQuantities.(probQuantityName)=tmpProbQuantities;
        end


        IsEmptyProbPropertyWithBadSize=...
        isempty(probQuantities.(varNames{i}))&&~isequal(obj.(SizeProperty).(varNames{i}),[0,0]);



        IsNonEmptyProbPropertyWithBadSize=...
        ~isequal(obj.(SizeProperty).(varNames{i}),size(probQuantities.(varNames{i})));


        if IsNonEmptyProbPropertyWithBadSize||IsEmptyProbPropertyWithBadSize
            error(message('optim_problemdef:OptimizationValues:ValuesAndProblemMustHaveSameSizes',probQuantityName));
        end
    end

end
