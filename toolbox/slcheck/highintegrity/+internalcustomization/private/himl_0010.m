function himl_0010

    rec=getNewCheckObject('mathworks.hism.himl_0010',false,@hCheckAlgo,'PostCompile');

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


        parentEML=eml_obj.ParentEML;
        if isempty(parentEML)
            return;
        end
        rp=Advisor.Utils.Eml.getEmlReport(parentEML);
    end
    if isempty(rp)
        return;
    end

    rpi=rp.inference;


    opNodes=mt.mtfind('Kind',{'ANDAND','OROR','NOT'});

    opFuncs=mt.mtfind('Kind','ID','String',{'and','xor','not','or'});

    indices=[opNodes.indices,opFuncs.indices];

    for i=1:length(indices)
        node=mt.select(indices(i));



        if strcmp(node.kind,'ID')
            lNode=node.Parent.Right;
            if strcmp(node.string,'not')
                rNode=node.Parent.Right;
            else
                rNode=node.Parent.Right.Next;
            end
            node=node.Parent;
        elseif strcmp(node.kind,'NOT')
            lNode=node.Arg;
            rNode=node.Arg;
        else
            lNode=node.Left;
            rNode=node.Right;
        end

        if isempty(lNode)||isempty(rNode)
            continue;
        end

        lDataType=Advisor.Utils.Eml.getDataTypeFromMnode(lNode,rpi);
        rDataType=Advisor.Utils.Eml.getDataTypeFromMnode(rNode,rpi);



        if strcmp(lDataType,'unknown')||strcmp(rDataType,'unknown')
            continue;
        end


        if~strcmp(lDataType,'logical')||~strcmp(rDataType,'logical')
            FailObjs=[FailObjs;getViolationInfoFromNode(eml_obj,node,[])];%#ok<AGROW>            
        end
    end

end