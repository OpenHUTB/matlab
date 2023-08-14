function open_from_ui(harnessOwner,harnessName,varargin)



    useMultipleHarnessOpen=slfeature('MultipleHarnessOpen');
    if useMultipleHarnessOpen
        harness=Simulink.harness.find(bdroot(harnessOwner),'Name',harnessName);
    else
        harness=Simulink.harness.find(bdroot(harnessOwner),'OpenOnly','on');
    end
    if~useMultipleHarnessOpen&&~isempty(harness)&&strcmp(harness.name,harnessName)&&strcmp(harness.ownerType,'Simulink.BlockDiagram')


        open_system(harness.name);
        return;
    elseif~useMultipleHarnessOpen&&~isempty(harness)&&~strcmp(harness.name,harnessName)


        systemModel=getfullname(bdroot(harnessOwner));
        msg=message('Simulink:Harness:AnotherHarnessAlreadyActivated',harnessName,harness.name,systemModel);
        ME=MException(msg);
        Simulink.harness.internal.error(ME,true,...
        'Simulink:Harness:OpenHarnessStage',systemModel);
    end


    Simulink.harness.internal.open(harnessOwner,harnessName,varargin{:});



    harness=Simulink.harness.find(harnessOwner,'Name',harnessName,'SearchDepth',0);

    if isempty(harness)||~harness.isOpen




        DAStudio.error('Simulink:Harness:OpenHarnessFailed');
    end
end

