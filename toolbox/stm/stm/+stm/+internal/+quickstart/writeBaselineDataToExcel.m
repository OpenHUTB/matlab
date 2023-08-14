function writeBaselineDataToExcel(signalSpecArr,tolStruct,datasetFilePath,spreadSheet,sheetName)


















    runID=stm.internal.util.createRunFromFile(signalSpecArr,datasetFilePath);


    ds=Simulink.sdi.exportRun(runID);


    xlsTolObj=locGetTolObject(tolStruct);


    xls.internal.util.writeDatasetToSheet(ds,spreadSheet,sheetName,'',xls.internal.SourceTypes.Output,0,xlsTolObj);

end

function tolObj=locGetTolObject(tolStruct)
    abs=[];rel=[];lead=[];lag=[];
    if(tolStruct.Abs>0)
        abs=tolStruct.Abs;
    end
    if(tolStruct.Rel>0)
        rel=tolStruct.Rel;
    end
    if(tolStruct.ForwardTimeTol>0)
        lead=tolStruct.ForwardTimeTol;
    end
    if(tolStruct.BackwardTimeTol>0)
        lag=tolStruct.BackwardTimeTol;
    end
    tolObj=xls.internal.Tolerance(abs,rel,lead,lag);
end



