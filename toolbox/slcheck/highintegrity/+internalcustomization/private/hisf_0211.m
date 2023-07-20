function hisf_0211

    rec=getNewCheckObject('mathworks.hism.hisf_0211',false,@hCheckAlgo,'PostCompile');
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
                    violations=[violations;iVerifyUnaryOpsC(system,roots{k},obj)];%#ok<AGROW>
                elseif Advisor.Utils.Stateflow.isActionLanguageM(chartObj)
                    violations=[violations;iVerifyUnaryOpsM(system,roots{k},obj,resolvedSymbolIds)];%#ok<AGROW>
                end
            end
        end
    end
end




function violations=iVerifyUnaryOpsC(system,ast,sfObj)



    violations=[];

    if(isa(ast,'Stateflow.Ast.Uminus'))
        if strcmp(Advisor.Utils.Stateflow.getAstDataType(system,ast.children{1},sfObj.chart),'unknown')
            return;
        end


        if contains(Advisor.Utils.Stateflow.getAstDataType(system,ast.children{1},sfObj.chart),'uint')
            tempFailObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(tempFailObj,'SID',sfObj,'Expression',ast.sourceSnippet,'TextStart',ast.treeStart,'TextEnd',ast.treeEnd);
            violations=[violations;tempFailObj];
        end

    end

    children=ast.children;
    for i=1:length(children)
        violations=[violations;iVerifyUnaryOpsC(system,children{i},sfObj)];%#ok<AGROW>
    end

end




function violations=iVerifyUnaryOpsM(system,ast,sfObj,resolvedSymbolIds)

    violations=[];

    if~isempty(ast.sourceSnippet)
        codeFragment=ast.sourceSnippet;
        mtreeObject=Advisor.Utils.Stateflow.createMtreeObject(codeFragment,resolvedSymbolIds);
        uminusNodes=mtreeObject.mtfind('Kind','UMINUS');

        for index=uminusNodes.indices
            thisNode=uminusNodes.select(index);
            uminusArg=thisNode.Arg;
            dataType=Advisor.Utils.Stateflow.getDataTypeFromTreeNode(system,uminusArg,resolvedSymbolIds);

            if strcmp(dataType,'unknown')==1
                return;
            end

            if isUnsignedInteger(dataType)
                leftIndex=ast.treeStart+thisNode.lefttreepos-1;
                rightIndex=ast.treeStart+thisNode.righttreepos-1;
                tempFailObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(tempFailObj,'SID',sfObj,'Expression',ast.sourceSnippet,'TextStart',leftIndex,'TextEnd',rightIndex);
                violations=[violations;tempFailObj];%#ok<AGROW>
            end
        end
    end
end




function result=isUnsignedInteger(dataType)
    switch dataType
    case 'uint8',result=true;
    case 'uint16',result=true;
    case 'uint32',result=true;
    otherwise,result=false;
    end
end