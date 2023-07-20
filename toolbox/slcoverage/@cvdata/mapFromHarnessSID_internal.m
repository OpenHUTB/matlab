function ssid=mapFromHarnessSID_internal(ssid,rootId,ownerBlock,analyzedModel)





    if~isempty(ownerBlock)&&...
        ~isempty(rootId)&&...
        ~isempty(cv('GetRootPath',rootId))
        modelName=bdroot(ownerBlock);
        res=Simulink.harness.internal.getActiveHarness(modelName);

        if~isempty(res)
            ssid=mapSSIDFromHarnessToModel(ownerBlock,analyzedModel,ssid);
        end
    end
end


function blockBlockSID=mapSSIDFromHarnessToModel(ownerBlock,analyzedModel,harnessBlockSID)
    blockBlockSID=harnessBlockSID;
    harnessObject=SlCov.FilterEditor.getObject(harnessBlockSID);
    if isempty(harnessObject)
        return;
    end



    if contains(class(harnessObject),'Stateflow.')
        chartObj=harnessObject.Chart;
        newChartSSID=mapSSIDFromHarnessToModel(ownerBlock,analyzedModel,Simulink.ID.getSID(chartObj));
        newChartModelObject=cvi.TopModelCov.getObject(newChartSSID);
        chart=newChartModelObject.find('-isa','Stateflow.Chart');
        newModelObject=chart.find('SSIdNumber',harnessObject.SSIdNumber);
        if isempty(newModelObject)
            return;
        end
        blockBlockSID=Simulink.ID.getSID(newModelObject);
    else
        harnessBlock=harnessObject.getFullName;
        if contains(harnessBlock,analyzedModel)
            modelBlock=[ownerBlock,harnessBlock(numel(analyzedModel)+1:end)];
            blockBlockSID=Simulink.ID.getSID(modelBlock);
        end
    end
end