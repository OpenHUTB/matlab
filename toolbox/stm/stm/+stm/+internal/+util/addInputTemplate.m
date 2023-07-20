


function[inpId]=addInputTemplate(tcpId,filePath,modelName,harnessName,sheet,range,addIterations,launchEditor)

    [modelToUse,deactivateHarness,currHarness,oldHarness,~,wasHarnessOpen]=stm.internal.util.resolveHarness(modelName,harnessName);


    inpDS=createInputDataset(modelToUse);


    fPath=which(filePath);

    if~isempty(fPath)
        filePath=fPath;
    end


    [~,~,ext]=fileparts(filePath);
    if(strcmpi(ext,'.mat'))
        save(filePath,'inpDS');
        options=addIterations;
    else
        simIndex=stm.internal.getTcpProperty(tcpId,'SimIndex');
        xls.internal.util.writeDatasetToSheet(...
        inpDS,filePath,sheet,range,xls.internal.SourceTypes.Input,simIndex);
        options.Sheets=string(sheet);
        options.Ranges=string(range);
        options.CreateIterations=addIterations;
    end

    ids=stm.internal.addInput(tcpId,filePath,true,options,true);

    inpId=ids(1);


    if~isempty(currHarness)
        close_system(currHarness.name,0);

        if(deactivateHarness)
            stm.internal.util.loadHarness(oldHarness.ownerFullPath,oldHarness.name,wasHarnessOpen);
        end
    end


    if launchEditor
        stm.internal.util.launchExternalFileEditor(filePath);
    end
end
