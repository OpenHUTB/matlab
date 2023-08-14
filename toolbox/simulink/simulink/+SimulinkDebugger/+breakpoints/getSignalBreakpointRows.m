function[children,breakpointIdx]=getSignalBreakpointRows(this,breakpointIdx,srcToBeHighlighted)








    studio=this.studio_;
    mdls=SimulinkDebugger.breakpoints.find_loaded_mdlrefs(studio.App.blockDiagramHandle);
    breakpointsInAllModels=[];
    for mdlIdx=1:numel(mdls)
        if bdIsLoaded(mdls{mdlIdx})
            breakpointsInAllModels=[breakpointsInAllModels,get_param(mdls{mdlIdx},'ConditionalPauseList')];%#ok<AGROW>
        end
    end

    children=[];

    for bpIdx=1:numel(breakpointsInAllModels)
        portHandle=breakpointsInAllModels(bpIdx).portHandle;
        data=breakpointsInAllModels(bpIdx).data;
        fullBlockPathToTopModel=breakpointsInAllModels(bpIdx).blockPath;

        dataSize=size(data);
        for bpsOnSig=1:dataSize(1)
            signalBp=SimulinkDebugger.breakpoints.SignalBreakpoint(...
            breakpointIdx,portHandle,data(bpsOnSig,:),...
            fullBlockPathToTopModel);
            childObj=SimulinkDebugger.breakpoints.BreakpointListSpreadsheetSignalRow(...
            signalBp,srcToBeHighlighted);
            children=[children,childObj];%#ok<AGROW>
            breakpointIdx=breakpointIdx+1;
        end

    end
end
