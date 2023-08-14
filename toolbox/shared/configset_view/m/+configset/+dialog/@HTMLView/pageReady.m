function pageReady(obj,~)






    if obj.deferredRefresh


        obj.deferredRefresh=false;
        obj.isWebPageReady=true;
        obj.refresh;

    else

        if~isempty(obj.params)
            obj.updateCallback();
        end


        msgs=obj.deferredMsgs;
        for i=1:length(msgs)
            action=msgs{i}{1};
            args=msgs{i}{2};
            obj.publish(action,args);
        end
        obj.deferredMsgs={};


        obj.isWebPageReady=true;
    end


