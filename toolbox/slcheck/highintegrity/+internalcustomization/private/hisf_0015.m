function hisf_0015

    rec=getNewCheckObject('mathworks.hism.hisf_0015',false,@hCheckAlgo,'PostCompile');
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
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});

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
                    violations=[violations;iVerifyCastingC(system,roots{k},obj)];%#ok<AGROW>
                elseif Advisor.Utils.Stateflow.isActionLanguageM(chartObj)
                    violations=[violations;iVerifyCastingM(system,roots{k},obj,resolvedSymbolIds)];%#ok<AGROW>
                end
            end
        end
    end
end




function violations=iVerifyCastingC(system,ast,sfObj)


    violations=[];
    if(Advisor.Utils.Stateflow.IsAComparison(ast)||...
        Advisor.Utils.Stateflow.IsAssignment(ast)||...
        isa(ast,'Stateflow.Ast.EqualAssignment'))
        [l_DataType,~]=Advisor.Utils.Stateflow.getAstDataType(system,ast.lhs,sfObj.chart);
        [r_DataType,~]=Advisor.Utils.Stateflow.getAstDataType(system,ast.rhs,sfObj.chart);

        UnaryMinusWithUint=(isa(ast.lhs,'Stateflow.Ast.Uminus')&&contains(r_DataType,'uint'))||(isa(ast.rhs,'Stateflow.Ast.Uminus')&&contains(l_DataType,'uint'));

        if(strcmp(l_DataType,'unknown')||strcmp(r_DataType,'unknown'))
            return;
        end


        if~strcmp(l_DataType,r_DataType)||UnaryMinusWithUint
            indices=[1,length(ast.sourceSnippet)];
            highlightText=Advisor.Utils.Stateflow.highlightSFLabelByIndex(ast.sourceSnippet,indices);
            tempFailObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(tempFailObj,'SID',sfObj,'Expression',highlightText.emitHTML);

            violations=[violations;tempFailObj];
        end
    end


    children=ast.children;
    for i=1:length(children)
        violations=[violations;iVerifyCastingC(system,children{i},sfObj)];%#ok<AGROW>
    end
end




function violations=iVerifyCastingM(system,ast,sfObj,resolvedSymbolIds)

    violations=[];
    codeFragment=ast.sourceSnippet;

    mtreeObject=Advisor.Utils.Stateflow.createMtreeObject(...
    codeFragment,resolvedSymbolIds);

    comparisonNodes=mtreeObject.mtfind('Kind',{'EQ','NE','GE','LE','GT','LT','EQUALS','PLUS','MINUS','MUL','DIV','LDIV'});
    for index=comparisonNodes.indices
        thisNode=comparisonNodes.select(index);

        [leftType,~]=Advisor.Utils.Stateflow.getDataTypeFromTreeNode(system,thisNode.Left,resolvedSymbolIds);
        [rightType,~]=Advisor.Utils.Stateflow.getDataTypeFromTreeNode(system,thisNode.Right,resolvedSymbolIds);

        if strcmp(leftType,'unknown')||strcmp(rightType,'unknown')
            return;
        end

        if~strcmp(leftType,rightType)
            leftIndex=thisNode.lefttreepos;
            rightIndex=thisNode.righttreepos;

            indices=[leftIndex,rightIndex];
            highlightText=Advisor.Utils.Stateflow.highlightSFLabelByIndex(ast.sourceSnippet,indices);
            tempFailObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(tempFailObj,'SID',sfObj,'Expression',highlightText.emitHTML);

            violations=[violations;tempFailObj];%#ok<AGROW>
        end

    end

end

