function addUnprotectedModel(h,blk)






    if strcmp(blk.Parent,h.CachedFullName)

        newnode=h.addChild(blk);
        newnode.populate;


        ed=DAStudio.EventDispatcher;
        ed.broadcastEvent('ChildAddedEvent',h,newnode);



        me=SigLogSelector.getExplorer;
        me.getRoot.modelBlockAddedOrRemoved;
    end


    if~isempty(h.childNodes)
        numChildren=h.childNodes.getCount();
        for chIdx=1:numChildren
            child=h.childNodes.getDataByIndex(chIdx);
            addUnprotectedModel(child,blk);
        end
    end

end
