function utilCallSdi(oldRunID,newRunID)

    mda=Simulink.ModelAdvisor;
    mdladvObj=mda.getActiveModelAdvisorObj();

    if isempty(mdladvObj.UserData.Progress.sdiRunIDs)
        return
    end

    sdiEngine=mdladvObj.UserData.Progress.sdiEngine;
    sdiGui=Simulink.sdi.Instance.gui();
    sdiGui.Show();

    pause(0.1);
    baseRunID=mdladvObj.UserData.Progress.sdiRunIDs(1);
    match=true;
    if sdiEngine.isValidRunID(newRunID)
        diff=Simulink.sdi.compareRuns(baseRunID,newRunID);
        sdiGui.changeTab(Simulink.sdi.GUITabType.CompareRuns);

        for i=1:diff.count
            diffSignal=diff.getResultByIndex(i);
            if(~diffSignal.match)
                match=false;
                signalID1=diffSignal.signalID1;
                sdiGui.plotSignalInComparedRun(signalID1);
                break;
            end
        end
        if(match)
            firstSignal=diff.getResultByIndex(1);
            firstSignalID1=firstSignal.signalID1;
            sdiGui.plotSignalInComparedRun(firstSignalID1);
        end
    end









