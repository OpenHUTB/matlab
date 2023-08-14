function sfData=getDataUsedInSFObj(sfObj)









    sfData=[];

    [asts,resolvedSymbolIds]=Advisor.Utils.Stateflow.getAbstractSyntaxTree(sfObj);

    if isempty(asts)
        return;
    end

    sections=asts.sections;

    if isempty(sections)
        return;
    end

    for secCount=1:numel(sections)
        section=sections{secCount};
        conditionRoots=section.roots;
        for c3=1:numel(conditionRoots)
            conditionRoot=conditionRoots{c3};
            if strcmp(sfObj.Chart.Actionlanguage,'C')

                if isa(conditionRoot,'Stateflow.Ast.IncrementAction')||...
                    isa(conditionRoot,'Stateflow.Ast.DecrementAction')

                    identifier=removeArrNotation(conditionRoot.sourceSnippet(1:end-2));
                    sfData=[sfData,{identifier}];

                elseif isa(conditionRoot,'Stateflow.Ast.EqualAssignment')
                    sfData=[sfData,getVariable(conditionRoot)];
                end
            else
                T=Advisor.Utils.Stateflow.createMtreeObject(...
                conditionRoot.sourceSnippet,resolvedSymbolIds);

                if isempty(T)
                    continue;
                end






                assignOp=T.find('Kind','ID');
                if~assignOp.isempty()
                    for index=assignOp.indices
                        thisNode=assignOp.select(index);
                        kind=thisNode.kind;
                        if~ischar(kind)
                            continue;
                        end
                        operand=thisNode.string;
                        if any(ismember(sfData,operand))
                            continue;
                        end
                        sfData=[sfData,{removeArrNotation(operand)}];
                    end
                end

            end
        end
    end
    sfData=unique(sfData);
end


function variable=getVariable(astRoot)


    variable=[];
    astChildren=astRoot.children;
    if isempty(astChildren)
        return;
    end
    for childCount=1:numel(astChildren)
        astChild=astChildren{childCount};
        if isa(astChild,'Stateflow.Ast.Identifier')
            variable=[variable,{removeArrNotation(astChild.sourceSnippet)}];
        end
        variable=[variable,getVariable(astChild)];
    end
end


function var=removeArrNotation(variable)

    var=variable;
    index=regexp(var,'({|\(|\[).*(}|\)|\])');
    if~isempty(index)
        var=variable(1:index-1);
    end
end

















