function changeModelName(oldModelName,newModelName)


    studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;

    if(~isempty(studios))
        st=studios(1);

        legendObj=Simulink.SampleTimeLegend;
        legendObj.clearHilite(newModelName,'task');

        Simulink.STOSpreadSheet.SortedOrder.launchExecutionOrderViewer(st);
    end

    if bdIsLoaded(newModelName)


        modelHandle=get_param(newModelName,'Handle');
        Simulink.addBlockDiagramCallback(modelHandle,...
        'PostNameChange','ExecutionOrderViewer',...
        @()Simulink.STOSpreadSheet.SortedOrder.changeModelName(newModelName,get_param(modelHandle,'Name')),...
        true);
    end

