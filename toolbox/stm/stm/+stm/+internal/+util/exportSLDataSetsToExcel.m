function[sheetsAdded]=exportSLDataSetsToExcel(excelFilePath,sldvData,...
    decimate,extractInfo,outputPortNames)






    SheetNamePrefix=message('stm:QuickStart:Scenarios_StepName').string;
    [in,out,param]=stm.internal.util.extractSLDataSets(sldvData,decimate,extractInfo);
    numOfTestCases=length(sldvData.TestCases);
    isExcelModified=false;

    existingSheets={};
    if exist(excelFilePath,'file')>0
        existingSheets=sheetnames(excelFilePath);
    end

    SheetNames(1:numOfTestCases)=SheetNamePrefix;
    [SheetNames,~]=matlab.lang.makeUniqueStrings(SheetNames,existingSheets,24);
    isExcelModified(1:numOfTestCases)=false;

    for idx=1:numOfTestCases
        SheetName=SheetNames(idx);
        if(~isempty(in))
            xls.internal.util.writeDatasetToSheet(in(idx),excelFilePath,...
            SheetName,'',xls.internal.SourceTypes.Input);
            isExcelModified(idx)=true;
        end
        if(~isempty(param))
            wt=xls.internal.WriteTable('Parameters',param{idx},'File',...
            excelFilePath,'sheet',SheetName);
            wt.write;
            isExcelModified(idx)=true;
        end
        if(~isempty(out))
            outDataset=out(idx);
            for elmIndx=1:outDataset.numElements
                outDataset{elmIndx}.Name=outputPortNames{elmIndx};
            end
            xls.internal.util.writeDatasetToSheet(outDataset,excelFilePath,...
            SheetName,'',xls.internal.SourceTypes.Output);
            isExcelModified(idx)=true;
        end
    end
    sheetsAdded=SheetNames(isExcelModified);

end