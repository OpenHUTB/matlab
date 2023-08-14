function himl_0009

    rec=getNewCheckObject('mathworks.hism.himl_0009',false,@hCheckAlgo,'PostCompile');

    rec.setReportStyle('ModelAdvisor.Report.ExpressionStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.ExpressionStyle'});

    rec.PreCallbackHandle=@Advisor.MATLABFileDependencyService.initialize;
    rec.PostCallbackHandle=@Advisor.MATLABFileDependencyService.reset;

    inputParamList=Advisor.Utils.Eml.getEMLStandardInputParams();

    rec.setInputParametersLayoutGrid([2,4]);
    rec.setInputParameters(inputParamList);

    rec.setLicense({HighIntegrity_License});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.register(rec);
end

function FailingObjs=hCheckAlgo(~)
    FailingObjs=[];
    fcnObjs=Advisor.MATLABFileDependencyService.getInstance.getRelevantEMLObjs();




    for i=1:length(fcnObjs)
        if~isempty(fcnObjs{i})
            FailingObjs=[FailingObjs;getFailingEMLFunctions(fcnObjs{i})];%#ok<AGROW>
        end
    end

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

    indices=getEqNodesFromMtree(mt);

    for i=1:length(indices)
        node=mt.select(indices(i));


        if strcmp(node.kind,'CALL')
            lNode=node.Right;
            rNode=node.Right.Next;
        else
            lNode=node.Left;
            rNode=node.Right;
        end

        lDataType=Advisor.Utils.Eml.getDataTypeFromMnode(lNode,rpi);
        rDataType=Advisor.Utils.Eml.getDataTypeFromMnode(rNode,rpi);



        if strcmp(lDataType,'unknown')||strcmp(rDataType,'unknown')
            continue;
        end


        if strcmp(lDataType,'double')||strcmp(rDataType,'double')||strcmp(lDataType,'single')||strcmp(rDataType,'single')
            FailObjs=[FailObjs;getViolationInfoFromNode(eml_obj,node,[])];%#ok<AGROW>            
        end
    end
end

function indices=getEqNodesFromMtree(mt)


    opNodes=mt.mtfind('Kind',{'EQ','NE'});

    fOpNodes=mt.mtfind('Kind',{'CALL'},'Left.String',{'eq','ne'});
    indices=[opNodes.indices,fOpNodes.indices];

end