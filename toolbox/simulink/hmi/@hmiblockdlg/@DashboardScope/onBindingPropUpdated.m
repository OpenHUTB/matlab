


function onBindingPropUpdated(blockHandle,propStr)
    dlg=hmiblockdlg.DashboardScope.findScopeDialog(blockHandle);
    if~isempty(dlg)
        [newSig,isSlimDlg]=locGetSignalPropFromSettings(jsondecode(propStr));
        idx=locFindSignal(dlg,newSig);
        if idx>0
            dlg.SelectedSignals{idx}=newSig;
        elseif strcmpi(newSig.checked,'true')
            dlg.SelectedSignals{end+1}=newSig;
        end


        mdl=get_param(bdroot(blockHandle),'Name');
        isLibWidget=Simulink.HMI.isLibrary(mdl);
        selectedSignals=utils.populateCurrentSelectedSignals(mdl,blockHandle,isLibWidget);
        utils.sendSelectedSignalsToScopeDialog(blockHandle,selectedSignals);


        if isSlimDlg
            dlg.applyBindingChanges();
        else
            signalDlgs=dlg.getOpenDialogs(true);
            for idx=1:length(signalDlgs)
                if signalDlgs{idx}.isStandAlone
                    signalDlgs{idx}.enableApplyButton(true,true);
                end
            end
        end
    end
end


function[newSig,isSlimDlg]=locGetSignalPropFromSettings(params)
    newSig=params.signal;
    isSlimDlg=strcmpi(params.isSlimDialog,'true');
    newSig.lineColor=eval(['[',newSig.lineColorTuples,']']);
    newSig.outputPortIndex=eval(newSig.outputPortIndex);

    if strcmpi(newSig.selection,'on')||strcmpi(newSig.selection,'true')
        newSig.checked='true';
    else
        newSig.checked='false';
    end

    newSig=rmfield(newSig,'model');
    newSig=rmfield(newSig,'selection');
    newSig=rmfield(newSig,'id');
    newSig=rmfield(newSig,'lineColorTuples');
end


function ret=locFindSignal(dlg,newSig)
    ret=0;
    for idx=1:length(dlg.SelectedSignals)
        if newSig.outputPortIndex==dlg.SelectedSignals{idx}.outputPortIndex&&...
            strcmp(newSig.blockPath,dlg.SelectedSignals{idx}.blockPath)&&...
            (isempty(newSig.signalName)||...
            isempty(dlg.SelectedSignals{idx}.signalName)||...
            strcmp(newSig.signalName,dlg.SelectedSignals{idx}.signalName))
            ret=idx;
            return
        end
    end
end
