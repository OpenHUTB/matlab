function state=reqMenuState(cbInfo,ctxId)









    if slreq.utils.selectionHasMarkup(cbInfo)
        state='Disabled';
        return;
    end




    selection=cbInfo.getSelection;
    if isempty(selection)

        sfRt=Stateflow.Root;
        selection=sfRt.idToHandle(ctxId);
    elseif length(selection)==1&&selection.Id~=ctxId



        sfRt=Stateflow.Root;
        selection=sfRt.idToHandle(ctxId);
    else

        for i=1:length(selection)
            if~selection(i).rmiIsSupported
                state='Hidden';
                return;
            end
        end
    end

    if rmisl.isComponentHarness(cbInfo.model.Name)
        if length(selection)~=1
            state='Disabled';
            return;
        end

        systemBD=Simulink.harness.internal.getHarnessOwnerBD(cbInfo.model.Name);
        if~Simulink.harness.internal.isReqLinkingSupportedForExtHarness(systemBD)
            state='Disabled';
            return;
        end
        if Simulink.harness.internal.sidmap.isObjectOwnedByCUT(selection)
            try
                selection=rmisl.harnessToModelRemap(selection);
            catch Mex
                if strcmp(Mex.identifier,'Simulink:utility:invalidSID')

                    state='Disabled';
                    return;
                else
                    rethrow(Mex);
                end
            end
        end
    elseif objectIsOpenedInActiveHarness(cbInfo.model.Name,selection)
        state='Disabled';
        return;
    end

    [rmiInstalled,rmiLicenseAvailable]=rmi.isInstalled();
    if rmiInstalled&&rmiLicenseAvailable
        state='Enabled';
    else
        if length(selection)>1
            state='Disabled';
        elseif~rmi.objHasReqs(selection,[])
            state='Disabled';
        else
            state='Enabled';
        end
    end
end

function yesno=objectIsOpenedInActiveHarness(modelName,objh)
    modelH=get_param(modelName,'Handle');
    if Simulink.harness.internal.hasActiveHarness(modelH)
        hasHarness=Simulink.harness.internal.hasActiveHarness(modelH);
        if~hasHarness
            yesno=false;
        else
            for i=1:length(objh)
                yesno=~isempty(Simulink.harness.internal.sidmap.getOwnerObjectSIDInHarness(objh(i)));
                if yesno
                    return;
                end
            end
        end
    else
        yesno=false;
    end
end

