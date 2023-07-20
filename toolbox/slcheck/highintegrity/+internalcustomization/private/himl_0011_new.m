function himl_0011_new

    rec=getNewCheckObject('mathworks.hism.himl_0011',false,@hCheckAlgo,'PostCompile');

    rec.setReportStyle('ModelAdvisor.Report.ExpressionStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.ExpressionStyle'});

    rec.PreCallbackHandle=@Advisor.MATLABFileDependencyService.initialize;
    rec.PostCallbackHandle=@Advisor.MATLABFileDependencyService.reset;

    inputParamList=Advisor.Utils.Eml.getEMLStandardInputParams();

    rec.setInputParametersLayoutGrid([2,4]);
    rec.setInputParameters(inputParamList);

    rec.setLicense({HighIntegrity_License});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});
end

function FailingObjs=hCheckAlgo(system)
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;
    fl_val=inputParams{2}.Value;
    lum_val=inputParams{3}.Value;

    FailingObjs=[];
    fcnObjs=Advisor.MATLABFileDependencyService.getInstance.getRelevantEMLObjs();



    for i=1:length(fcnObjs)
        if~isempty(fcnObjs{i})
            FailingObjs=[FailingObjs;getFailingEMLFunctions(fcnObjs{i})];%#ok<AGROW>
        end
    end


    FailingObjs=[FailingObjs;hCheckAlgoSF(system,fl_val,lum_val)];

end

function FailObjs=getFailingEMLFunctions(eml_obj)
    FailObjs={};

    switch class(eml_obj)
    case{'Stateflow.EMChart','Stateflow.EMFunction'}
        mt=mtree(eml_obj.Script,'-com','-cell','-comments');
        rp=Advisor.Utils.Eml.getEmlReport(eml_obj);

    case 'struct'
        mt=mtree(eml_obj.FileName,'-com','-cell','-file','-comments');


        parentObj=Advisor.Utils.Eml.getEMLParentOfReferencedFile(eml_obj);
        if isempty(parentObj)
            return;
        end
        rp=Advisor.Utils.Eml.getEmlReport(parentObj);
    end

    if isempty(rp)
        return;
    end

    rpi=rp.inference;

    indices=getRelOpNodesFromMtree(mt);

    for i=1:length(indices)
        node=mt.select(indices(i));
        if strcmp(node.kind,'LT')&&strcmp(node.Parent.kind,'CEXPR')
            continue;
        end

        lDataType=Advisor.Utils.Eml.getDataTypeFromMnode(node.Left,rpi);



        if~strcmp(lDataType,'unknown')&&~strcmp(lDataType,'logical')
            FailObjs=[FailObjs;getViolationInfoFromNode_loc(eml_obj,node)];%#ok<AGROW>            
        end
    end
end

function indices=getRelOpNodesFromMtree(mt)


    opNodes=mt.mtfind('Kind',{'IFHEAD','ELSEIF','WHILE'});
    indices=opNodes.indices;
end

function violationObj=getViolationInfoFromNode_loc(object,node)
    violationObj=ModelAdvisor.ResultDetail;

    nodeStrCell=strsplit(node.Left.tree2str,newline);
    if isa(object,'struct')
        ModelAdvisor.ResultDetail.setData(violationObj,'FileName',object.FileName,'Expression',[strtrim(nodeStrCell{1}),'...'],'TextStart',node.position,'TextEnd',node.endposition);
    else
        ModelAdvisor.ResultDetail.setData(violationObj,'SID',object,'Expression',[strtrim(nodeStrCell{1}),'...'],'TextStart',node.position-1,'TextEnd',node.endposition);
    end
end


function violationsSF=hCheckAlgoSF(system,fl_val,lum_val)
    violationsSF=[];

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    allSfObjs=Advisor.Utils.Stateflow.sfFindSys(system,fl_val,lum_val,{'-isa','Stateflow.State','-or','-isa','Stateflow.Transition'},true);
    allSfObjs=mdladvObj.filterResultWithExclusion(allSfObjs);

    for i=1:numel(allSfObjs)
        obj=allSfObjs{i};
        chartObj=obj.chart;
        [asts,resolvedSymbolIds]=Advisor.Utils.Stateflow.getAbstractSyntaxTree(obj);

        if isempty(asts)||Advisor.Utils.Stateflow.isActionLanguageC(chartObj)
            continue;
        end

        sections=asts.sections;
        for j=1:length(sections)

            roots=sections{j}.roots;
            if isa(sections{j},'Stateflow.Ast.ConditionSection')
                for m=1:length(roots)
                    violationsSF=[violationsSF;locVerifyMCondTrans(system,roots{m},obj,resolvedSymbolIds)];
                end
            else
                for k=1:length(roots)
                    violationsSF=[violationsSF;locVerifyM(system,roots{k},obj,resolvedSymbolIds)];
                end
            end
        end
    end
end

function violations=locVerifyM(system,ast,sfObj,resolvedSymbolIds)
    violations=[];
    codeFragment=ast.sourceSnippet;
    mt=Advisor.Utils.Stateflow.createMtreeObject(codeFragment,resolvedSymbolIds);
    indices=getRelOpNodesFromMtree(mt);

    for i=1:length(indices)
        node=mt.select(indices(i));
        if strcmp(node.kind,'LT')&&strcmp(node.Parent.kind,'CEXPR')
            continue;
        end
        lDataType=Advisor.Utils.Stateflow.getDataTypeFromTreeNode(system,node.Left,resolvedSymbolIds);



        if~strcmp(lDataType,'unknown')&&~strcmp(lDataType,'logical')&&~strcmp(lDataType,'boolean')
            leftIndex=ast.treeStart+node.lefttreepos-1;
            rightIndex=ast.treeStart+node.righttreepos-1;
            tempFailObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(tempFailObj,'SID',sfObj,'Expression',ast.sourceSnippet,'TextStart',leftIndex,'TextEnd',rightIndex);
            violations=[violations;tempFailObj];
        end
    end
end

function violations=locVerifyMCondTrans(system,ast,sfObj,resolvedSymbolIds)
    violations=[];
    codeFragment=ast.sourceSnippet;
    mt=Advisor.Utils.Stateflow.createMtreeObject(codeFragment,resolvedSymbolIds);
    node=mt.mtfind();
    lDataType=Advisor.Utils.Stateflow.getDataTypeFromTreeNode(system,node.select(2),resolvedSymbolIds);
    if~strcmp(lDataType,'unknown')&&~strcmp(lDataType,'logical')&&~strcmp(lDataType,'boolean')
        leftIndex=ast.treeStart+node.select(2).lefttreepos-1;
        rightIndex=ast.treeStart+node.select(2).righttreepos-1;
        tempFailObj=ModelAdvisor.ResultDetail;
        ModelAdvisor.ResultDetail.setData(tempFailObj,'SID',sfObj,'Expression',ast.sourceSnippet,'TextStart',leftIndex,'TextEnd',rightIndex);
        violations=[violations;tempFailObj];
    end
end