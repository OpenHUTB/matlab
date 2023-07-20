function lambdaOut=mapLambdaSolution(prob,lambdaIn)














    lambdaOut.Variables=[];
    lambdaOut.Constraints=[];
    varStruct=prob.Variables;
    varNames=fieldnames(varStruct);

    if~isempty(lambdaIn)

        for k=1:numel(varNames)

            thisVarName=varNames{k};
            thisVar=varStruct.(thisVarName);
            thisVarOffset=getOffset(thisVar);
            thisVarSize=size(thisVar);
            thisVarNumel=prod(thisVarSize);


            lambdaOut.Variables.(thisVarName).Lower=reshape(...
            lambdaIn.lower(thisVarOffset:thisVarOffset+thisVarNumel-1),thisVarSize);
            lambdaOut.Variables.(thisVarName).Upper=reshape(...
            lambdaIn.upper(thisVarOffset:thisVarOffset+thisVarNumel-1),thisVarSize);
        end
    else

        emptyStruct.Lower=[];
        emptyStruct.Upper=[];
        lambdaOut.Variables=cell2struct(repmat({emptyStruct},numel(varNames),1),varNames,1);
    end

    constraints=prob.Constraints;
    if isstruct(constraints)
        constrNames=fieldnames(constraints);
        if~isempty(lambdaIn)
            isConicProblem=any(strcmp(fieldnames(lambdaIn),'soc'));
            eqlinOffset=1;
            eqnonlinOffset=1;
            ineqlinOffset=1;
            ineqnonlinOffset=1;

            for i=1:numel(constrNames)

                constrName=constrNames{i};
                thisConstr=constraints.(constrName);
                if~isempty(thisConstr)
                    isNonlinConstr=~isLinear(thisConstr);
                    thisConstrSize=size(thisConstr);
                    m=numel(thisConstr);


                    if strcmp(getRelation(thisConstr),'==')
                        if isNonlinConstr
                            lambdaOut.Constraints.(constrName)=reshape(...
                            lambdaIn.eqnonlin(eqnonlinOffset:eqnonlinOffset+m-1),thisConstrSize);
                            eqnonlinOffset=eqnonlinOffset+m;
                        else
                            lambdaOut.Constraints.(constrName)=reshape(...
                            lambdaIn.eqlin(eqlinOffset:eqlinOffset+m-1),thisConstrSize);
                            eqlinOffset=eqlinOffset+m;
                        end
                    else
                        if isNonlinConstr
                            if isConicProblem
                                lmName="soc";
                            else
                                lmName="ineqnonlin";
                            end
                            lambdaOut.Constraints.(constrName)=reshape(...
                            lambdaIn.(lmName)(ineqnonlinOffset:ineqnonlinOffset+m-1),thisConstrSize);
                            ineqnonlinOffset=ineqnonlinOffset+m;
                        else
                            lambdaOut.Constraints.(constrName)=reshape(...
                            lambdaIn.ineqlin(ineqlinOffset:ineqlinOffset+m-1),thisConstrSize);
                            ineqlinOffset=ineqlinOffset+m;
                        end
                    end
                else
                    lambdaOut.Constraints.(constrName)=[];
                end
            end
        else

            lambdaOut.Constraints=cell2struct(repmat({[]},numel(constrNames),1),constrNames,1);
        end
    elseif~isempty(constraints)


        constrSize=size(constraints);
        if~isempty(lambdaIn)
            isConicProblem=any(strcmp(fieldnames(lambdaIn),'soc'));
            isNonlinConstr=~isLinear(constraints);
            if strcmp(getRelation(constraints),'==')
                if isNonlinConstr
                    lambdai=reshape(lambdaIn.eqnonlin,constrSize);
                else
                    lambdai=reshape(lambdaIn.eqlin,constrSize);
                end
            else
                if isNonlinConstr
                    if isConicProblem
                        lmName="soc";
                    else
                        lmName="ineqnonlin";
                    end
                    lambdai=reshape(lambdaIn.(lmName),constrSize);
                else
                    lambdai=reshape(lambdaIn.ineqlin,constrSize);
                end
            end
        else
            lambdai=[];
        end
        lambdaOut.Constraints=lambdai;
    end
end
