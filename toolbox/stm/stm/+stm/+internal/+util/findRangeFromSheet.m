function range=findRangeFromSheet(filePath,sheet,startRange,type)









    if~isempty(startRange)
        startRange=strsplit(startRange,':');
        startRange=startRange{1};
    end


    sourceType=xls.internal.SourceTypes.Output;
    if type==1
        sourceType=xls.internal.SourceTypes.Input;
    end
    T=xls.internal.ReadTable(filePath,'sheet',sheet,'range',string(startRange));
    ds=T.readMetadata(sourceType);
    range=T.getRange.Range_;
end