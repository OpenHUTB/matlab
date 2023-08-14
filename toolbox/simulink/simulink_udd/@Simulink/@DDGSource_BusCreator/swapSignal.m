function swapSignal(~,dlg,signalsToHilite)




    widgetName='MatchInputsString';
    if dlg.getWidgetValue(widgetName)==1
        newInd=signalsToHilite;
        dlg.setWidgetValue('signalsList',[]);
        dlg.setWidgetValue('signalsList',newInd-1);
    else
        dlg.setWidgetValue('sigselector_signalsTree','');
        dlg.setWidgetValue('sigselector_signalsTree',signalsToHilite);
        dlg.getDialogSource.signalSelector.selectSignalInTree(dlg);
    end

    dlg.enableApplyButton(1);

