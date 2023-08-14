function prob=subsasgn(prob,s,expr)










    try
        if strcmp(s(1).type,'.')


            propertyName=s(1).subs;

            settingObjectives=strcmp(propertyName,'ObjectivesStore');
            settingConstraints=strcmp(propertyName,'ConstraintsStore');



            canAddVars=false;

            if settingObjectives||settingConstraints









                if~settingNestedProperty(s)
                    if settingConstraints
                        expr=prob.checkValidConstraints(expr);
                    else
                        settingLabelledObjective=...
                        length(s)==2&&strcmp(s(2).type,'.');
                        expr=prob.checkValidObjectives(expr,settingLabelledObjective);
                    end

                    canAddVars=canAddVariablesFromExprOrConstr(prob,propertyName,s);
                end

                if length(s)==2

                    refType=s(2).type;

                    if strcmp(refType,'.')

                        if~isstruct(prob.(propertyName))||isempty(prob.(propertyName))



                            exprStruct.(s(2).subs)=expr;
                            expr=exprStruct;
                            s=s(1);

                        end

                    elseif strcmp(refType,'{}')


                        error(prob.MessageCatalogID+':NoCellAccess',...
                        getString(message('MATLAB:cellAssToNonCell')));
                    end
                elseif length(s)==3










                    origConstr=builtin('subsref',prob,s(1:2));

                    origConstr=subsasgn(origConstr,s(3),expr);

                    prob=builtin('subsasgn',prob,s(1:2),origConstr);




                    prob=makeVariablesList(prob);
                    return;
                end
            elseif strcmp(propertyName,'Variables')
                if numel(s)>2

                    var=builtin('subsref',prob,s(1:2));

                    var=builtin('subsasgn',var,s(3:end),expr);%#ok<NASGU> var is a handle.
                else
                    error(prob.MessageCatalogID+':VariablesReadOnly',...
                    getString(message('optim_problemdef:ProblemImpl:VariablesReadOnly')));
                end
            end
        end


        prob=builtin('subsasgn',prob,s,expr);



        if settingObjectives||settingConstraints
            prob.Compiler.reset();
        end

        if canAddVars

            if isstruct(expr)
                newLabels=fieldnames(expr);
                for i=1:numel(newLabels)
                    prob.Variables=addVariablesFromExprOrConstr(...
                    prob.Variables,expr.(newLabels{i}),prob.className);
                end
            else
                prob.Variables=addVariablesFromExprOrConstr(...
                prob.Variables,expr,prob.className);
            end
        else

            prob=makeVariablesList(prob);
        end

    catch E
        throwAsCaller(E)
    end


    function TorF=settingNestedProperty(s)









        nLevels=length(s);
        exprAndConstrPropNames={'IndexNames','Variables'};
        TorF=(nLevels==2&&strcmp(s(2).type,'.')&&any(strcmp(s(2).subs,exprAndConstrPropNames)))||...
        (nLevels>2&&all(strcmp({s(2:3).type},'.'))&&any(strcmp(s(3).subs,exprAndConstrPropNames)));



        function canAddVars=canAddVariablesFromExprOrConstr(prob,propertyName,s)


            canAddVars=false;

            currentProp=prob.(propertyName);






            assignSingleLabeledConstr=length(s)>1;
            emptyProbConstr=isempty(currentProp);
            structProbConstr=isstruct(currentProp);

            if emptyProbConstr


                canAddVars=true;
            elseif assignSingleLabeledConstr&&structProbConstr




                newLabel=s(2).subs;
                oldLabels=fieldnames(currentProp);
                if any(ismember(oldLabels,newLabel))


                else


                    canAddVars=true;
                end
            end