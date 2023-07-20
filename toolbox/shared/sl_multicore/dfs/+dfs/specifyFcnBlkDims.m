function action_performed=specifyFcnBlkDims(theBlkPath,portIdx,isInput)


    action_performed='';

    blkHandle=getSimulinkBlockHandle(theBlkPath);
    chartId=sfprivate('block2chart',blkHandle);
    chartH=sf('IdToHandle',chartId);

    if isInput
        scopeVal='Input';
    else
        scopeVal='Output';
    end

    theData=chartH.find('-isa','Stateflow.Data',...
    'Scope',scopeVal,'Port',portIdx);

    theData.view;

end
