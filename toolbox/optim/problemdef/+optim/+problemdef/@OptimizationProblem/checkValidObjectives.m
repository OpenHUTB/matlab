function objectiveOut=checkValidObjectives(objectiveIn,settingLabelledObjective)







    if isstruct(objectiveIn)
        if isscalar(objectiveIn)
            objLabels=fieldnames(objectiveIn);
            objectiveExpr=struct2cell(objectiveIn);
        else

            error(message('optim_problemdef:OptimizationProblem:ObjectiveNotExpression'));
        end
    else
        objectiveExpr={objectiveIn};
    end


    numLabelledObj=numel(objectiveExpr);


    for i=1:numLabelledObj
        if~isempty(objectiveExpr{i})

            objectiveExpr{i}=i_castVariableOrDouble(objectiveExpr{i});
        end
    end


    if isstruct(objectiveIn)
        for i=1:numLabelledObj
            i_checkScalarExpression(objectiveExpr{i});
        end
        objectiveOut=cell2struct(objectiveExpr,objLabels);
    elseif settingLabelledObjective
        i_checkScalarExpression(objectiveExpr{1});
        objectiveOut=objectiveExpr{1};
    else
        i_checkExpression(objectiveExpr{1});
        objectiveOut=objectiveExpr{1};
    end

    function expr=i_castVariableOrDouble(expr)



        if isnumeric(expr)



            try
                expr=optim.problemdef.OptimizationNumeric(expr);
            catch ME
                throwAsCaller(ME);
            end
        elseif isa(expr,'optim.problemdef.OptimizationVariable')
            expr=optim.problemdef.OptimizationExpression(expr);
        end

        function i_checkScalarExpression(objectiveExpr)

            if~(i_isEmptyDouble(objectiveExpr)||...
                (isa(objectiveExpr,'optim.problemdef.OptimizationExpression')&&...
                (all(size(objectiveExpr)==0)||isscalar(objectiveExpr))))
                throwAsCaller(MException(message('optim_problemdef:OptimizationProblem:ObjectiveNotExpression')));

            end

            function isExpr=i_isEmptyDouble(objectiveExpr)







                isExpr=(isa(objectiveExpr,'double')&&all(size(objectiveExpr)==0));

                function i_checkExpression(objectiveExpr)


                    if~(i_isEmptyDouble(objectiveExpr)||isa(objectiveExpr,'optim.problemdef.OptimizationExpression'))
                        throwAsCaller(MException(message('optim_problemdef:OptimizationProblem:ObjectiveNotExpression')));
                    end



