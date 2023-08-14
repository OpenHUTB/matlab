function setSource(obj,cs,refresh)




    if nargin<3
        refresh=true;
    end

    adp=configset.internal.getConfigSetAdapter(cs);
    pre=obj.Source;

    if adp==pre
        if refresh
            obj.refresh();
        end
        return;
    end

    if~isempty(pre)
        pre.detachView();
    end

    adp.ensureServiceOn();
    obj.fSourceListener=event.listener(adp,'CSEvent',@obj.update);
    obj.Source=adp;
    adp.attachView();


    if refresh
        obj.refresh();
    end

