function styleguide_jc_0481

    rec=Advisor.Utils.getDefaultCheckObject('mathworks.maab.jc_0481',false,@hCheckAlgo,'PostCompile');

    rec.setReportStyle('ModelAdvisor.Report.ExpressionStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.ExpressionStyle'});

    rec.setLicense({styleguide_license,'Stateflow'});

    rec.setInputParametersLayoutGrid([1,4]);

    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[2,2];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[2,2];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';

    rec.setInputParameters(inputParamList);

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});

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
                    violations=[violations;locVerifyC(system,roots{k},obj)];%#ok<AGROW>
                elseif Advisor.Utils.Stateflow.isActionLanguageM(chartObj)
                    violations=[violations;locVerifyM(system,roots{k},obj,resolvedSymbolIds)];%#ok<AGROW>
                end
            end
        end
    end
end

function violations=locVerifyC(system,ast,sfObj)
    violations=[];


    if isa(ast,'Stateflow.Ast.IsEqual')||isa(ast,'Stateflow.Ast.IsNotEqual')||isa(ast,'Stateflow.Ast.NegEqual')
        [l_DataType,~]=Advisor.Utils.Stateflow.getAstDataType(system,ast.lhs,sfObj.chart);
        [r_DataType,~]=Advisor.Utils.Stateflow.getAstDataType(system,ast.rhs,sfObj.chart);



        floatingType=strcmp(l_DataType,'single')||strcmp(l_DataType,'double')||strcmp(r_DataType,'single')||strcmp(r_DataType,'double');
        if(strcmp(l_DataType,'unknown')||strcmp(r_DataType,'unknown'))
            return;
        end
        if floatingType
            tempFailObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(tempFailObj,'SID',sfObj,'Expression',ast.sourceSnippet,'TextStart',ast.treeStart,'TextEnd',ast.treeEnd);
            violations=[violations;tempFailObj];
        end
    end


    children=ast.children;
    for i=1:length(children)
        violations=[violations;locVerifyC(system,children{i},sfObj)];%#ok<AGROW>
    end

end

function violations=locVerifyM(system,ast,sfObj,resolvedSymbolIds)

    violations=[];
    codeFragment=ast.sourceSnippet;

    mtreeObject=Advisor.Utils.Stateflow.createMtreeObject(...
    codeFragment,resolvedSymbolIds);

    comparisonNodes=mtreeObject.mtfind('Kind',{'EQ','NE'});

    for index=comparisonNodes.indices
        thisNode=comparisonNodes.select(index);

        [leftType,~]=Advisor.Utils.Stateflow.getDataTypeFromTreeNode(system,thisNode.Left,resolvedSymbolIds);
        [rightType,~]=Advisor.Utils.Stateflow.getDataTypeFromTreeNode(system,thisNode.Right,resolvedSymbolIds);

        if strcmp(leftType,'unknown')||strcmp(rightType,'unknown')
            return;
        end

        if strcmp(leftType,'single')||strcmp(leftType,'double')||strcmp(rightType,'single')||strcmp(rightType,'double')
            leftIndex=ast.treeStart+thisNode.lefttreepos-1;
            rightIndex=ast.treeStart+thisNode.righttreepos-1;
            tempFailObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(tempFailObj,'SID',sfObj,'Expression',ast.sourceSnippet,'TextStart',leftIndex,'TextEnd',rightIndex);
            violations=[violations;tempFailObj];%#ok<AGROW>
        end

    end

end


