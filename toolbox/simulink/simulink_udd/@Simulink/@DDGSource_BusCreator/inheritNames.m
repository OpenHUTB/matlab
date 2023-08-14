function inheritNames(this,dlg,tag)




    if strcmp(tag,'InheritFromInputs')
        if(dlg.getWidgetValue(tag)==false)
            if(dlg.getWidgetValue('MatchInputsString')==1)
                dlg.setWidgetValue('MatchInputsString',0);
                tag='MatchInputsString';
            else
                return;
            end
        else
            return;
        end
    elseif strcmp(tag,'MatchInputsString')
        if(dlg.getWidgetValue(tag)==true)
            if(dlg.getWidgetValue('InheritFromInputs')==0)
                dlg.setWidgetValue('InheritFromInputs',1);
            end
        end
    else
        return;
    end

    if dlg.getWidgetValue(tag)==0
        dlg.setVisible('upButton',1);
        dlg.setVisible('downButton',1);
        dlg.setVisible('addButton',1);
        dlg.setVisible('removeButton',1);
        dlg.setVisible('refreshButton',1);
        dlg.setVisible('findButton',1);
        dlg.setVisible('removeButton',1);
        dlg.setVisible('signalsList',0);
        dlg.setVisible('signalSelectorGroup',1);

        dlg.setVisible('renameEdit',0);
        dlg.setVisible('signalListPanel',0);


        tcp=this.signalSelector.TCPeer;
        if~(tcp.isAnyTreeSelection)
            dlg.setEnabled('findButton',0);
        else
            dlg.setEnabled('findButton',1);
        end




        selectionNames=tcp.FullItemNames(tcp.SelectedIDs);
        for i=1:length(selectionNames)
            if~isempty(strfind(selectionNames{i},'.'))
                dlg.setEnabled('addButton',0);
                break;
            end
        end

    else

        dlg.setVisible('upButton',1);
        dlg.setVisible('downButton',1);
        dlg.setVisible('refreshButton',0);
        dlg.setVisible('signalsList',1);
        dlg.setVisible('signalSelectorGroup',0);
        dlg.setVisible('findButton',0);
        dlg.setVisible('addButton',1);
        dlg.setVisible('removeButton',1);

        dlg.setVisible('renameEdit',1);
        dlg.setVisible('signalListPanel',1);
    end

    this.setUpDownRenameWidgetStatus(dlg,'signalsList');

    dlg.resetSize(false);
end
