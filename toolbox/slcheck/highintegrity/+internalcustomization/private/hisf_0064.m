function hisf_0064

    rec=getNewCheckObject('mathworks.hism.hisf_0064',false,@hCheckAlgo,'PostCompile');
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

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;

    allSfObjs=Advisor.Utils.Stateflow.sfFindSys(system,inputParams{1}.Value,inputParams{2}.Value,{'-isa','Stateflow.State','-or','-isa','Stateflow.Transition'},true);
    allSfObjs=mdladvObj.filterResultWithExclusion(allSfObjs);

    for i=1:numel(allSfObjs)
        obj=allSfObjs{i};
        chartObj=obj.chart;
        [asts,resolvedSymbolIds]=Advisor.Utils.Stateflow.getAbstractSyntaxTree(obj);
        if isempty(asts)
            continue;
        end


        sections=asts.sections;
        for j=1:length(sections)
            roots=sections{j}.roots;
            for k=1:length(roots)
                if Advisor.Utils.Stateflow.isActionLanguageC(chartObj)
                    violations=[violations;iVerifyShiftC(system,roots{k},obj)];%#ok<AGROW>
                elseif Advisor.Utils.Stateflow.isActionLanguageM(chartObj)
                    violations=[violations;iVerifyShiftM(system,roots{k},obj,resolvedSymbolIds)];%#ok<AGROW>
                end
            end
        end
    end
end




function violations=iVerifyShiftC(system,ast,sfObj)
    violations=[];

    if(isa(ast,'Stateflow.Ast.ShiftRight')||isa(ast,'Stateflow.Ast.ShiftLeft'))

        l_DataWidth=Advisor.Utils.Stateflow.getDataBitwidth(Advisor.Utils.Stateflow.getAstDataType(system,ast.lhs,sfObj.chart));


        if isa(ast.rhs,'Stateflow.Ast.IntegerNum')||isa(ast.rhs,'Stateflow.Ast.FloatNum')
            r_ShiftVal=ast.rhs.value;
        elseif isa(ast.rhs,'Stateflow.Ast.Identifier')
            try
                r_ShiftVal=evalinGlobalScope(bdroot(system),ast.rhs.sourceSnippet);
            catch
                r_ShiftVal=NaN;
            end
        else
            r_ShiftVal=NaN;
        end

        if(isnan(l_DataWidth)||isnan(r_ShiftVal))
            return;
        end

        if(r_ShiftVal>l_DataWidth)
            tempFailObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(tempFailObj,'SID',sfObj,'Expression',ast.sourceSnippet,'TextStart',ast.treeStart,'TextEnd',ast.treeEnd);
            violations=[violations;tempFailObj];
        end
    end


    children=ast.children;
    for i=1:length(children)
        violations=[violations;iVerifyShiftC(system,children{i},sfObj)];%#ok<AGROW>
    end
end




function violations=iVerifyShiftM(system,ast,sfObj,resolvedSymbolIds)
    violations=[];

    codeFragment=ast.sourceSnippet;

    mtreeObject=Advisor.Utils.Stateflow.createMtreeObject(codeFragment,resolvedSymbolIds);

    comparisonNodes=mtreeObject.mtfind('Fun',{'bitsll','bitsrl','bitshift','bitshift'});
    for index=comparisonNodes.indices
        thisNode=comparisonNodes.select(index);

        inputBitwidth=Advisor.Utils.Stateflow.getDataBitwidth(Advisor.Utils.Stateflow.getDataTypeFromTreeNode(system,thisNode.Parent.Right,resolvedSymbolIds));

        if strcmp(thisNode.Parent.Right.Next.kind,'INT')||strcmp(thisNode.Parent.Right.Next.kind,'DOUBLE')
            shiftVal=str2num(thisNode.Parent.Right.Next.string);%#ok<ST2NM>
        elseif strcmp(thisNode.Parent.Right.Next.kind,'ID')
            try
                shiftVal=evalinGlobalScope(bdroot(system),thisNode.Parent.Right.Next.string);
            catch
                shiftVal=NaN;
            end
        else
            shiftVal=NaN;
        end


        if isnan(inputBitwidth)||isnan(shiftVal)
            return;
        end

        if shiftVal>inputBitwidth
            leftIndex=ast.treeStart+thisNode.lefttreepos-1;
            rightIndex=ast.treeStart+thisNode.righttreepos-1;
            tempFailObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(tempFailObj,'SID',sfObj,'Expression',ast.sourceSnippet,'TextStart',leftIndex,'TextEnd',rightIndex);
            violations=[violations;tempFailObj];%#ok<AGROW>
        end
    end
end
