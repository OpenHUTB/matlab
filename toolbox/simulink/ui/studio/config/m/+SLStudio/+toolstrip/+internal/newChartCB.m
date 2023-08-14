function newChartCB(cbinfo)



    if SLStudio.toolstrip.internal.isStateflowApp(cbinfo)
        Stateflow.App.Studio.CreateNewSFXWithUserName();
    elseif~isempty(ver('stateflow'))
        sltemplate.ui.StartPage.newStateflowSFView();
    else
        sfnew;
    end
end

