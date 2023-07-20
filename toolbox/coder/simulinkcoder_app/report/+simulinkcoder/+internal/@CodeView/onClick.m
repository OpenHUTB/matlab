function onClick(obj,src,evt)



    if~strcmp(obj.cid,evt.cid)
        return;
    end

    model=evt.model;
    studio=obj.studio;

    switch evt.action
    case 'code2mapping'
        d=evt.userData;
        d.sid=evt.sids{1};
        simulinkcoder.internal.util.highlightMapping(model,studio,d);
    end