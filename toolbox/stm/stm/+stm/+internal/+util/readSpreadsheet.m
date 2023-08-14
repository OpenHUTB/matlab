function[dSet,readTable]=readSpreadsheet(srcId,spreadSheet,type,allowEmpty)


    [sheets,ranges,model,~]=stm.internal.getSheetRangeInfo(srcId,type);


    modelCloseObj=Simulink.SimulationData.ModelCloseUtil();
    if(~isempty(model)&&~bdIsLoaded(model))
        try
            load_system(model);
        catch

            model='';
        end
    end


    readTable=xls.internal.ReadTable(spreadSheet,'Sheets',sheets,'Ranges',ranges,'Model',model);
    dSet=readTable.readMetadata(xls.internal.SourceTypes.Output);

    delete(modelCloseObj);

    if dSet.numElements==0&&~allowEmpty

        if length(sheets)==1
            error(message('stm:BaselineCriteria:UnsupportedSheet',sheets{1}));
        else

            error(message('stm:BaselineCriteria:UnsupportedFile'));
        end
    end
end