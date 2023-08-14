function value=evalSubsysExpr(modelName,path,key)







    value=[];
    if~isempty(path)&&~matches(path,{'\','/'})


        subSysPath=fileparts(path);


        subsysBlocks=arrayfun(@(x)(string(x)),(find_system(modelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','SubSystem')));
        subsysExists=false;
        if~isempty(subsysBlocks)
            subsysExists=any(matches(subsysBlocks,subSysPath));
        end
        if subsysExists
            try

                maskParams=struct2table(Simulink.Mask.get(char(subSysPath)).getWorkspaceVariables);

                editFieldExpr=get_param(path,key);
                if ischar(editFieldExpr)

                    inlineExpr=inline(editFieldExpr);

                    exprArgNames=argnames(inlineExpr);


                    exprArgsVals=arrayfun(@(x)(maskParams(matches(maskParams.Name,x),:).Value),exprArgNames);

                    inlineExprStr='inlineExpr(';
                    for eId=1:numel(exprArgsVals)
                        inlineExprStr=[inlineExprStr,arrayToChar(exprArgsVals(eId))];
                        if eId~=numel(exprArgsVals)
                            inlineExprStr=[inlineExprStr,','];
                        end
                    end
                    inlineExprStr=[inlineExprStr,');'];


                    value=eval(inlineExprStr);
                end
            catch
                try

                    retVal=coder.internal.getDataObjectPropertyValue(modelName,get_param(subSysPath,key),data);
                    if~retVal{1}
                        value=evalinGlobalScope(modelName,get_param(subSysPath,key));
                    else
                        value=retVal{2};
                    end
                catch
                    try
                        editfieldExpr=get_param(subSysPath,key);
                        value=eval(editfieldExpr);
                    catch
                        value=[];
                    end
                end
            end
        end
    end
end



function charExp=arrayToChar(val)
    if iscell(val)
        val=val{1};
    end
    charExp='reshape([';
    charExp=[charExp,char(join(string(val(:)),' '))];
    charExp=[charExp,'],['];
    charExp=[charExp,char(join(string(size(val)),' '))];
    charExp=[charExp,'])'];
end


