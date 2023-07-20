function linkRefresher(cbinfo,action)
    r=fromContextMenu();
    if isempty(r)
        return;
    end
    switch action.name
    case 'add:linkWithSL'
        action.enabled=fromOnOff(r.sl.enabled);
        action.text=r.sl.name;
    case 'add:linkWithZC'
        action.enabled=fromOnOff(r.zc.enabled);
        action.text=r.zc.name;
    case 'add:linkWithTestAction'
        action.enabled=fromOnOff(r.test.enabled);
        action.text=r.test.name;
    case 'add:selectForLink'
        action.enabled=fromOnOff(r.req.enabled);
        action.text=r.req.name;
    case 'add:linkWithMatlab'
        ml=slreq.internal.gui.enableLinkWithMatlab();
        action.enabled=ml.enabled;
        action.text=ml.name;
    case 'add:linkWithDD'
        dd=slreq.internal.gui.enableLinkWithDD();
        action.enabled=dd.enabled;
        action.text=dd.name;
    case 'add:linkWithReq'
        action.enabled=fromOnOff(r.fromTo.enabled);
        action.text=r.fromTo.name;
    case 'add:linkWithFA'
        fa=slreq.internal.gui.enableLinkWithFA();
        action.enabled=fa.enabled;
        action.text=fa.name;
    case 'add:linkWithSM'
        safetymgr=slreq.internal.gui.enableLinkWithSafetyManager();
        action.enabled=safetymgr.enabled;
        action.text=safetymgr.name;
    end
end

function tf=fromOnOff(str)
    tf=strcmpi(str,'on');
end

function r=fromContextMenu()
    editor=slreq.app.MainManager.getInstance.requirementsEditor;
    sels=editor.getCurrentSelection;
    if~isempty(sels)

        items=sels(1).getContextMenuItems('standalone');
    else
        r=struct([]);
        return;
    end

    r=struct();
    for i=items
        for s=i{:}
            switch s.tag
            case 'Requirement:LinkWithSelectedBlock'
                r.sl=s;
            case 'Requirement:LinkWithSelectedZCViewElement'
                r.zc=s;
            case 'Requirement:LinkWithSelectedTest'
                r.test=s;
            case 'Requirement:SelectForLinkingWithReq'
                r.req=s;
            case 'Requirement:LinkFromTo'
                r.fromTo=s;
            end
        end
    end



    if isempty(fieldnames(r))
        r=struct([]);
        return;
    end

    if~isfield(r,'fromTo')

        r.fromTo=struct('name',getString(message('Slvnv:slreq:LinkWithReq')),'enabled','off');
    end

    actual=fieldnames(r);
    expected={'sl','zc','test','req','fromTo'};
    notPresent=setdiff(expected,actual);
    if~isempty(notPresent)
        disp(notPresent);
        assert(false,'missing link context menus!');
    end
end
