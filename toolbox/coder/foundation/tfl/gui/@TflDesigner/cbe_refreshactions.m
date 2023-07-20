function cbe_refreshactions(me,e)






    if~isempty(me)&&~isempty(me.getRoot)


        me.getRoot.currenttreenode=e.EventData;
        if~me.getRoot.iseditorbusy
            me.getRoot.lastactionnodepath=e.EventData.path;


            me.updateactions;
            e.EventData.firelistchanged;
        end
    end

