function children=getHierarchicalChildren(h)





    children=[];


    if isempty(h.childNodes)||~h.childNodes.getCount()
        return;
    end


    me=SigLogSelector.getExplorer;
    bViewMasks=true;
    bViewLinks=true;
    bViewAll=false;
    if~isempty(me)
        act=me.getAction('VIEW_MASKS');
        bViewMasks=strcmpi(act.on,'on');

        act=me.getAction('VIEW_LINKS');
        bViewLinks=strcmpi(act.on,'on');

        act=me.getAction('VIEW_ALL_SUBSYS');
        bViewAll=strcmpi(act.on,'on');
    end


    idx=1;
    numChildren=h.childNodes.getCount();
    me=SigLogSelector.getExplorer;
    for chIdx=1:numChildren

        thisChild=h.childNodes.getDataByIndex(chIdx);
        if isempty(thisChild)||~ishandle(thisChild)
            continue;
        end


        if isempty(thisChild.daobject)
            continue;
        end






        if~isempty(me)&&...
            strcmp('running',me.status)&&...
            ~isa(thisChild.daobject,'DAStudio.Object')&&...
            ~isa(thisChild.daobject,'Simulink.DABaseObject')
            blk=get_param(thisChild.CachedFullName,'Object');
            thisChild.daobject=blk;
        end

        if~isa(thisChild.daobject,'DAStudio.Object')&&~isa(thisChild.daobject,'Simulink.DABaseObject')





            jhc=h.childNodes;


            h.childNodes.Clear;
            curNumChildren=jhc.getCount();
            for i=1:curNumChildren
                child=jhc.getDataByIndex(i);


                if isa(child.daobject,'DAStudio.Object')||isa(child.daobject,'Simulink.DABaseObject')
                    h.childNodes.insert(child.daobject.Name,child);
                end
            end
            jhc.Clear;
            unpopulate(thisChild);


            ed=DAStudio.EventDispatcher;
            ed.broadcastEvent('ChildRemovedEvent',h,thisChild);
            continue;
        end



        if~thisChild.getNodeIsVisible(bViewMasks,bViewLinks,bViewAll)
            continue;
        end

        if(isempty(children))
            children=thisChild;
        else
            children(idx)=thisChild;%#ok<AGROW>
        end
        idx=idx+1;
    end

end
