function setEnableForGenerateSummaryCheckBox(cbInfo,action)




    action.selected=cbInfo.Context.Object.App.ReductionOptions.GenerateDetailedSummary;
    action.enabled=license('test','SIMULINK_Report_Gen');
end
