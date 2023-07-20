function remove_hook(~,dlg)





    widgetName='MatchInputsString';
    if dlg.getWidgetValue(widgetName)==1
        if isempty(dlg.getWidgetValue('signalsList'))

            numSignals=length(dlg.getUserData('signalsList'));
            dlg.setWidgetValue('signalsList',numSignals-1);
        end
    else
        imd=DAStudio.imDialog.getIMWidgets(dlg);
        tree=find(imd,'tag','sigselector_signalsTree');
        tree_items=tree.getTreeItems;
        val=dlg.getWidgetValue('sigselector_signalsTree');
        if isempty(val)
            count=0;
            while iscell(tree_items{end-count})
                count=count+1;
            end
            dlg.setWidgetValue('sigselector_signalsTree',tree_items{end-count});
        end
        dlg.getDialogSource.signalSelector.selectSignalInTree(dlg);
    end

    dlg.enableApplyButton(1);
end
