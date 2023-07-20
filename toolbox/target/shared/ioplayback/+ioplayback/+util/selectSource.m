function selectSource(block)



    datasetName=get_param(gcb,'DatasetName');
    h=ioplayback.util.SourceSelector(datasetName);
    openDialog(h,@dialogCloseCallback);

    function dialogCloseCallback(isAcceptedSelection,sourceName)
        if isAcceptedSelection
            set_param(block,'SourceName',sourceName);
            if isequal(get_param(gcb,'maskType'),'IO Data Source')
                gcbh=get_param(block,'Handle');
                soc.internal.IODataSourceCb('MaskParamCb',gcbh,'SourceName');
            end
        end
    end
end
