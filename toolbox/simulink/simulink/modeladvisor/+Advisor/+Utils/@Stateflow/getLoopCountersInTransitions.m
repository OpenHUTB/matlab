function[targetVariable]=getLoopCountersInTransitions(gPath,sfJunctionMap)















    cycleJunctionIds=arrayfun(@(x)sfJunctionMap(x),gPath);

    tempVarHolder1=[];
    tempVarHolder2=[];


    for c1=1:numel(gPath)


        sfJ=idToHandle(sfroot,sfJunctionMap(gPath(c1)));
        sfT=sfJ.sourcedTransitions;

        if strcmp(sfJ.Chart.Actionlanguage,'C')
            Cflag=true;
        else
            Cflag=false;
        end

        for c2=1:numel(sfT)



            destinationJunction=sfT(c2).Destination;
            if~any(ismember(cycleJunctionIds,destinationJunction.Id))
                continue;
            end











            asts=Advisor.Utils.Stateflow.getAbstractSyntaxTree(sfT(c2));

            if isempty(asts)
                continue;
            end

            conditionSection=asts.conditionSection;
            conditionActionSection=asts.conditionActionSection;

            if~isempty(conditionSection)

                conditionSection=conditionSection{1};
                conditionRoot=conditionSection.roots{1};


                if Cflag

                    if isa(conditionRoot,'Stateflow.Ast.LesserThan')||...
                        isa(conditionRoot,'Stateflow.Ast.LesserThanOrEqual')||...
                        isa(conditionRoot,'Stateflow.Ast.GreaterThan')||...
                        isa(conditionRoot,'Stateflow.Ast.GreaterThanOrEqual')

                        identifier=conditionRoot.lhs;
                        tempVarHolder1=[tempVarHolder1,...
                        {removeArrNotation(identifier.sourceSnippet)}];


                    elseif isa(conditionRoot,'Stateflow.Ast.IsEqual')
                        identifier=conditionRoot.lhs;
                        targetVariable={removeArrNotation(identifier.sourceSnippet)};
                        return;
                    end
                else



                    T=mtree(conditionRoot.sourceSnippet);

                    if isempty(T)
                        continue;
                    end


                    relop=T.mtfind('Kind',{'LT','GT','GE','LE'});

                    if~relop.isempty()
                        for index=relop.indices
                            thisNode=relop.select(index);
                            operands=thisNode.operands;
                            for operIndex=operands.indices
                                operNode=operands.select(operIndex);
                                kind=operNode.kind;
                                if ischar(kind)
                                    if strcmp('CALL',kind)
                                        varNode=operNode.Left;
                                        tempVarHolder1=[tempVarHolder1,...
                                        {removeArrNotation(varNode.string)}];
                                    end
                                end
                            end
                        end
                    end

                end
            end





            if~isempty(conditionActionSection)
                conditionActionSection=conditionActionSection{1};
                conditionRoots=conditionActionSection.roots;
                for c3=1:numel(conditionRoots)
                    conditionRoot=conditionRoots{c3};

                    if Cflag
                        if isa(conditionRoot,'Stateflow.Ast.IncrementAction')||...
                            isa(conditionRoot,'Stateflow.Ast.DecrementAction')

                            identifier=removeArrNotation(conditionRoot.sourceSnippet(1:end-2));
                            tempVarHolder2=[tempVarHolder2,{identifier}];

                        elseif isa(conditionRoot,'Stateflow.Ast.EqualAssignment')

                            rhs=conditionRoot.rhs;

                            if isa(rhs,'Stateflow.Ast.Plus')||...
                                isa(rhs,'Stateflow.Ast.Minus')

                                identifier=conditionRoot.lhs;
                                tempVarHolder2=[tempVarHolder2,{removeArrNotation(identifier.sourceSnippet)}];

                            end
                        end
                    else


                        T=mtree(conditionRoot.sourceSnippet);

                        if isempty(T)
                            continue;
                        end

                        arthOp=T.mtfind('Kind',{'PLUS','MINUS'});

                        if~arthOp.isempty()
                            for index=arthOp.indices
                                thisNode=arthOp.select(index);
                                operands=thisNode.operands;
                                for operIndex=operands.indices
                                    operNode=operands.select(operIndex);
                                    kind=operNode.kind;
                                    if ischar(kind)
                                        if strcmp('ID',kind)
                                            tempVarHolder2=[tempVarHolder2,{removeArrNotation(operNode.string)}];
                                        end
                                    end
                                end
                            end
                        end

                    end
                end

            end
        end
    end




    if isempty(tempVarHolder1)||isempty(tempVarHolder2)
        targetVariable=[];
        return
    end

    targetVariable=intersect(tempVarHolder1,tempVarHolder2);

end

function var=removeArrNotation(variable)

    var=variable;
    index=regexp(var,'({|\(|\[).*(}|\)|\])');
    if~isempty(index)
        var=variable(1:index-1);
    end
end
