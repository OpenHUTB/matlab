function ShowBlockDiagramConditionalPauseList_ForSFCharts(modelH,chartId,toggleBpList)












    obj=SLStudio.GetBlockDiagramConditionalPauseListDialog(modelH);
    editor=StateflowDI.SFDomain.getLastActiveEditorForChart(chartId);
    studio=editor.getStudio();
    obj.showBlockDiagramConditionalPauseListDialog_helper(studio,0,toggleBpList);
end