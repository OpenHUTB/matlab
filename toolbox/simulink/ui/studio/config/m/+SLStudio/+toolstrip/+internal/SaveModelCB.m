function SaveModelCB(cbinfo)


    chartId=SFStudio.Utils.getChartId(cbinfo);
    if chartId&&Stateflow.App.IsStateflowApp(chartId)
        Stateflow.App.Studio.ToolBars('SaveCB',cbinfo,chartId);
        return
    end

    hasRefModels=length(cbinfo.studio.App.getBlockDiagramHandles())>1;
    if(hasRefModels||SLStudio.toolstrip.internal.haveDirtySSRefModels(cbinfo))
        SLM3I.saveBlockDiagramAndDirtyRefModels(cbinfo.model.Handle);
    else
        SLM3I.saveBlockDiagram(cbinfo.model.Handle);
    end
end
