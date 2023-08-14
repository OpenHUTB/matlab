function bindableData=getBindableData(sourceBlock,selectionHandles)







    try

        SigOrGen=get_param(sourceBlock.sourceElementHandle,'IOType');

        if~strcmp(SigOrGen,'siggen')
            str=get_param(sourceBlock.sourceElementPath,'Name');
            ME=MException('SignalSelectorBindMode:sourceBlockNotSiggen',...
            'Source block is not a signal generator',str);
            throw(ME);
        end

        bindableData.bindableRows=[];
        bindableData.updateDiagramButtonRequired=false;


        signalHandles=get_param(sourceBlock.sourceElementHandle,'IOSignals');


        slsignalselector.utils.hiliteSelectedSignals([signalHandles{1}.Handle]);


        connectedRows=slsignalselector.PortSelectorBindMode.getConnectedRowsForSigGen(signalHandles);
        selectionRows=slsignalselector.PortSelectorBindMode.getUnconnectedPortRowsInSelection(selectionHandles,true);



        combinedRows=BindMode.utils.combineSelectedAndConnectedRows(selectionRows,connectedRows);

        bindableData.updateDiagramButtonRequired=false;
        bindableData.bindableRows=combinedRows;
    catch ex
        bindableData=[];
        bindableData.updateDiagramButtonRequired=false;
        if isa(ex,'MException')
            disp(ex.message);
        end
    end

end
