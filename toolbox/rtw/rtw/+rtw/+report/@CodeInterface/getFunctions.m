function[functions,descriptions,semantics]=getFunctions(obj,codeInfo,expInports)
    import mlreportgen.dom.*
    ssH=obj.getLinkManager().SourceSubsystem;
    if isempty(ssH)
        ssH=[];
    else
        ssH=get_param(ssH,'Handle');
    end
    portH=get_param(ssH,'PortHandles');


    functions=[codeInfo.AllocationFunction(:);codeInfo.InitializeFunctions(:);codeInfo.OutputFunctions(:);codeInfo.UpdateFunctions(:);codeInfo.TerminateFunctions(:)];


    descriptions=cell(length(functions),1);
    semantics=cell(length(functions),1);
    idx=1;
    for k=1:length(codeInfo.AllocationFunction)
        descriptions{idx}=DAStudio.message('RTW:codeInfo:reportAllocationDescription');
        semantics{idx}=getFunctionCallSemantics(functions(idx));
        idx=idx+1;
    end
    for k=1:length(codeInfo.InitializeFunctions)
        descriptions{idx}=DAStudio.message('RTW:codeInfo:reportInitializationDescription');
        semantics{idx}=getFunctionCallSemantics(functions(idx));
        idx=idx+1;
    end
    for k=1:length(codeInfo.OutputFunctions)
        if isempty(expInports)
            descriptions{idx}=DAStudio.message('RTW:codeInfo:reportOutputDescription');
        elseif~isempty(portH)
            portNum=arrayfun(@(x)(strcmp(x.('PortType'),'fcn_call')&&x.('Index')==k),expInports,'UniformOutput',true);
            if length(expInports)==length(portH.Inport)
                blockH=rtwprivate('slbus','LocalGetBlockForPortPrm',portH.Inport(portNum),'Handle');
            else


                blockH=rtwprivate('slbus','LocalGetBlockForPortPrm',portH.Trigger,'Handle');
            end
            out=obj.getHyperlink(Simulink.ID.getSID(blockH));
            descriptions{idx}=DAStudio.message('RTW:codeInfo:reportExportedFuncDescription',out);
        end
        semantics{idx}=getFunctionCallSemantics(functions(idx));
        idx=idx+1;
    end
    for k=1:length(codeInfo.UpdateFunctions)
        descriptions{idx}=DAStudio.message('RTW:codeInfo:reportUpdateDescription');
        semantics{idx}=getFunctionCallSemantics(functions(idx));
        idx=idx+1;
    end
    for k=1:length(codeInfo.TerminateFunctions)
        descriptions{idx}=DAStudio.message('RTW:codeInfo:reportTerminationDescription');
        semantics{idx}=getFunctionCallSemantics(functions(idx));
        idx=idx+1;
    end
end
