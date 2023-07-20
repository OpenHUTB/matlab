function gw=generateFilteredViewPopup(cbinfo)
    mgr=slreq.app.MainManager.getInstance;
    vm=mgr.viewManager;
    vm.refreshView;

    menu=slreq.internal.gui.generateFilteredViewPopupMenu();

    gw=dig.GeneratedWidget(cbinfo.EventData.namespace,cbinfo.EventData.type);
    cb=menu.callback;

    for i=1:numel(menu.items)
        item=menu.items{i};
        for j=1:numel(item)
            entry=item(j);
            if entry.isHeader
                widget=gw.Widget.addChild('PopupListHeader',entry.tag);
                widget.Label=entry.label;
                continue;
            else
                widget=gw.Widget.addChild('ListItem',entry.tag);
            end
            widget.ActionId=['filterViewRadioButtonPopupList:',entry.tag];

            action=gw.createAction(entry.tag);
            action.text=entry.label;
            action.enabled=true;
            action.setCallbackFromArray({cb,entry.callbackArg},dig.model.FunctionType.Action);
            action.eventDataType=dig.model.EventDataType.Boolean;
        end

        if i~=numel(menu.items)
            gw.Widget.addChild('Separator',['viewlistSeperator',num2str(i)]);
        end
    end

end
