function obsPrtBlks=getObserverPortBlocks(selection,modelName)
    import Simulink.observer.internal.getObsRefAndPrtPairsForSFState;
    obsPrtBlks=[];
    if isempty(selection)||bdIsLibrary(modelName)
        return;
    elseif sltest.internal.menus.isSupportedState(selection)
        chartBlkH=sfprivate('chart2block',selection.Chart.Id);
        obsPrtBlks=getObsRefAndPrtPairsForSFState(chartBlkH,num2str(selection.ssIdNumber),'All');
        return;
    end

    for j=1:numel(selection)
        if~(isa(selection(j),'Simulink.Segment')&&strcmp(selection(j).LineType,'signal'))
            return;
        end
    end
    prtH=unique(arrayfun(@(x)get_param(x.Handle,'SrcPortHandle'),selection));

    if isscalar(prtH)&&prtH~=-1&&~strcmp(get_param(prtH,'PortType'),'connection')
        parentBlkH=get_param(get_param(prtH,'Parent'),'Handle');
        portNumber=get_param(prtH,'PortNumber')-1;
        obsPrtBlks=Simulink.observer.internal.getObsRefAndPrtPairsForOutport(parentBlkH,portNumber);
    end
end
