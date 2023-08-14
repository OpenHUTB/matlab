function reqUpdateTable(cbinfo)



    chartH=cbinfo.uiObject;
    if~license('test','Simulink_Design_Verifier')
        Stateflow.Diagnostics.reportError(chartH.Id,'Stateflow:requirementstable:AnalysisRequiresSLDV',sf('GetHyperLinkedNameForObject',chartH.Id));
    end

    editor=StateflowDI.SFDomain.getLastActiveEditorForChart(chartH.Id);
    hid=editor.getHierarchyId;
    chartBlkH=SLM3I.SLCommonDomain.getSLHandleForHID(hid);

    obj=sfreq.internal.analysis.ReqTableAnalysis(chartBlkH,...
    'includeEntireModel',sf('get',chartH.Id,'.reqTable.includeEntireModelForAnalysis'));
    obj.doAnalysis();
end
