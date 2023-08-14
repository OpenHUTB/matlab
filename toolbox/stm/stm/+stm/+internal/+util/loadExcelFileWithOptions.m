function[varsLoadedStruct,varsValue]=loadExcelFileWithOptions(inputFilePath,...
    excelSheets,ranges,model,sourceType,load,simIndex)




    if isempty(excelSheets)
        excelSheets=sheetnames(inputFilePath);
    end

    nSheets=length(excelSheets);
    if isempty(ranges)
        ranges=strings([1,nSheets]);
    end

    for x=1:nSheets
        T=xls.internal.ReadTable(inputFilePath,'Sheets',excelSheets(x),...
        'Ranges',ranges(x),'Model',model);
        val=T.readMetadata(sourceType,simIndex);
        varName=genvarname(excelSheets(x));

        if(load)
            varsLoadedStruct(x)=varName;
            varsValue(x)=val;
            assignin('base',varsLoadedStruct{x},val);
        else
            varsLoadedStruct.(varName{1})=val;
        end
    end
end
