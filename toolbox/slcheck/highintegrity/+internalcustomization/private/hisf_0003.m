function hisf_0003

    rec=getNewCheckObject('mathworks.hism.hisf_0003',false,@hCheckAlgo,'PostCompile');

    rec.setReportStyle('ModelAdvisor.Report.ExpressionStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.ExpressionStyle'});

    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='all';

    rec.setInputParametersLayoutGrid([1,4]);
    rec.setInputParameters(inputParamList);

    rec.setLicense({HighIntegrity_License,'Stateflow'});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.register(rec);
end

function violations=hCheckAlgo(system)
    violations=[];
    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdlAdvObj.getInputParameters;

    sfObjs=Advisor.Utils.Stateflow.sfFindSys(system,inputParams{1}.Value,inputParams{2}.Value,{'-isa','Stateflow.State','-or','-isa','Stateflow.Transition'},true);
    sfObjs=mdlAdvObj.filterResultWithExclusion(sfObjs);

    for i=1:length(sfObjs)

        chartObj=sfObjs{i}.Chart;

        [asts,resolvedId]=Advisor.Utils.Stateflow.getAbstractSyntaxTree(sfObjs{i});
        if isempty(asts)
            continue;
        end


        sections=asts.sections;
        for j=1:length(sections)
            roots=sections{j}.roots;
            for k=1:length(roots)
                if Advisor.Utils.Stateflow.isActionLanguageC(chartObj)
                    violations=[violations,iVerifyBitwiseOps(system,sfObjs{i},roots{k})];%#ok<AGROW>
                else
                    violations=[violations,iVerifyBitwiseOpsM(system,sfObjs{i},roots{k},resolvedId)];%#ok<AGROW>
                end
            end
        end
    end
end

function violations=iVerifyBitwiseOps(system,sfObj,ast)

    violations=[];
    chartObj=sfObj.Chart;

    if~chartObj.EnableBitOps
        return;
    end


    if isa(ast,'Stateflow.Ast.BitAnd')||isa(ast,'Stateflow.Ast.BitOr')||isa(ast,'Stateflow.Ast.BitXor')

        lDataType=Advisor.Utils.Stateflow.getAstDataType(system,ast.lhs,chartObj);
        rDataType=Advisor.Utils.Stateflow.getAstDataType(system,ast.rhs,chartObj);

        if strcmp(lDataType,'unknown')||strcmp(rDataType,'unknown')
            return;
        end

        if isaSignedDataType(lDataType)||isaSignedDataType(rDataType)
            tempFailObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(tempFailObj,'SID',sfObj,'Expression',ast.sourceSnippet);
            violations=[violations,tempFailObj];
        end
    elseif isa(ast,'Stateflow.Ast.ShiftLeft')||isa(ast,'Stateflow.Ast.ShiftRight')
        lDataType=Advisor.Utils.Stateflow.getAstDataType(system,ast.lhs,chartObj);
        [rDataType,isConst]=Advisor.Utils.Stateflow.getAstDataType(system,ast.rhs,chartObj);

        if strcmp(lDataType,'unknown')||strcmp(rDataType,'unknown')
            return;
        end






        if isaSignedDataType(lDataType)||(~isConst&&isaSignedDataType(rDataType))||(isConst&&(strcmp(rDataType,'double')))
            tempFailObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(tempFailObj,'SID',sfObj,'Expression',ast.sourceSnippet);
            violations=[violations,tempFailObj];
        end
    elseif isa(ast,'Stateflow.Ast.Negate')
        dType=Advisor.Utils.Stateflow.getAstDataType(system,ast.children{1},chartObj);

        if strcmp(dType,'unknown')
            return;
        end

        if isaSignedDataType(dType)
            tempFailObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(tempFailObj,'SID',sfObj,'Expression',ast.sourceSnippet);
            violations=[violations,tempFailObj];
        end
    end


    children=ast.children;
    for i=1:length(children)
        violations=[violations,iVerifyBitwiseOps(system,sfObj,children{i})];%#ok<AGROW>
    end
end

function violations=iVerifyBitwiseOpsM(system,sfObj,ast,resolvedSymbolIds)

    violations=[];violations1=[];

    codeFragment=ast.sourceSnippet;

    mtreeObject=Advisor.Utils.Stateflow.createMtreeObject(codeFragment,resolvedSymbolIds);

    nodes=mtreeObject.mtfind('Fun',{'bitsll','bitsrl','bitshift','bitand','bitor','bitxor','bitcmp','bitset','bitget','swapbytes'});
    for index=nodes.indices
        thisNode=nodes.select(index);

        [aResult,violations1]=isaassumedDataType(thisNode);
        if aResult
            if violations1
                tempFailObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(tempFailObj,'SID',sfObj,'Expression',ast.sourceSnippet);
                violations=[violations,tempFailObj];%#ok<AGROW>
            end
        else
            switch(thisNode.string)
            case{'bitand','bitor','bitxor'}

                lDataType=Advisor.Utils.Stateflow.getDataTypeFromTreeNode(system,thisNode.Parent.Right,resolvedSymbolIds);
                rDataType=Advisor.Utils.Stateflow.getDataTypeFromTreeNode(system,thisNode.Parent.Full.Next,resolvedSymbolIds);

                if strcmp(lDataType,'unknown')||strcmp(rDataType,'unknown')
                    return;
                end


                if isaSignedDataType(lDataType)||isaSignedDataType(rDataType)
                    tempFailObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(tempFailObj,'SID',sfObj,'Expression',ast.sourceSnippet);
                    violations=[violations,tempFailObj];%#ok<AGROW>
                end

            case{'bitsll','bitsrl','bitshift','bitset','bitget'}
                lDataType=Advisor.Utils.Stateflow.getDataTypeFromTreeNode(system,thisNode.Parent.Right,resolvedSymbolIds);

                if strcmp(lDataType,'unknown')
                    return;
                end





                treeNodes=thisNode.Parent.Full.Next;
                treeNodesIndices=treeNodes.indices;
                for treeNodesIndex=treeNodesIndices
                    [rDataType,isConst]=Advisor.Utils.Stateflow.getDataTypeFromTreeNode(system,treeNodes.select(treeNodesIndex),resolvedSymbolIds);



                    if strcmp(rDataType,'unknown')
                        return;
                    end
                    if isaSignedDataType(lDataType)||(~isConst&&isaSignedDataType(rDataType))||(isConst&&(strcmp(rDataType,'double')))
                        tempFailObj=ModelAdvisor.ResultDetail;
                        ModelAdvisor.ResultDetail.setData(tempFailObj,'SID',sfObj,'Expression',ast.sourceSnippet);
                        violations=[violations,tempFailObj];%#ok<AGROW>
                    end
                end

            case{'bitcmp','swapbytes'}
                dType=Advisor.Utils.Stateflow.getDataTypeFromTreeNode(system,thisNode.Parent.Right,resolvedSymbolIds);

                if strcmp(dType,'unknown')
                    return;
                end

                if isaSignedDataType(dType)
                    tempFailObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(tempFailObj,'SID',sfObj,'Expression',ast.sourceSnippet);
                    violations=[violations,tempFailObj];%#ok<AGROW>
                end
            otherwise
                continue;
            end
        end
    end

end

function bResult=isaSignedDataType(datatype)
    bResult=any(strcmp(datatype,{'int8','int16','int32','int64','double','single'}))||startsWith(datatype,'fixdt(1')||startsWith(datatype,'sfix');
end



function[aResult,violation]=isaassumedDataType(thisNode)
    aResult=false;violation=false;
    tempVar=thisNode.Parent.Full;
    opNodes=tempVar.mtfind('Kind','CHARVECTOR');
    if~isempty(opNodes)
        indices=opNodes.indices;
        node=opNodes.select(indices);
        assumedatatype=strrep(node.string,'''','');
        violation=any(strcmp(assumedatatype,{'int8','int16','int32','int64','double','single'}))||startsWith(assumedatatype,'fixdt(1')||startsWith(assumedatatype,'sfix');
        aResult=true;
    end
end