



function bool=shouldCloseHarness(modelToRun,mainModel,nextMainModel,nextHarnessString)
    bool=false;
    if isequal(modelToRun,mainModel)
        return;
    end

    activeHarness=Simulink.harness.find(mainModel,'Name',modelToRun,'OpenOnly','on');
    if isempty(activeHarness)
        return;
    end

    nextHarness='';
    if~isempty(nextHarnessString)
        ind=strfind(nextHarnessString,'%%%');
        if~isempty(ind)
            nextHarnessName=nextHarnessString(1:ind(1)-1);
            nextOwnerName=nextHarnessString(ind(1)+3:end);
        else
            nextHarnessName=nextHarnessString;
            nextOwnerName=nextMainModel;
        end
        if bdIsLoaded(nextMainModel)&&~isempty(nextOwnerName)&&~isempty(nextHarnessName)
            nextHarness=Simulink.harness.find(nextOwnerName,'Name',nextHarnessName);
        end
    end

    apps=[SLM3I.StudioApp.empty,DAS.Studio.getAllStudiosSortedByMostRecentlyActive.App];
    isHarnessOpen=any(get_param([apps.blockDiagramHandle],'Name')==string(activeHarness.name));

    if isequal(activeHarness,nextHarness)
        bool=false;
    elseif strcmp(modelToRun,activeHarness.name)&&isHarnessOpen
        bool=false;
    elseif strcmp(get_param(activeHarness.name,'FastRestart'),'on')
        bool=false;
    else
        bool=true;
    end
end
