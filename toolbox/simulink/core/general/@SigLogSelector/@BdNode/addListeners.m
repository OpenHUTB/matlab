function addListeners(h)





    if~h.isLoaded
        return;
    end

    ed=DAStudio.EventDispatcher;
    me=SigLogSelector.getExplorer;








    if~isempty(me)
        me.getRoot.skipAllPropChangeEvents=true;
    end
    warn_state=warning('off','all');
    daevents.broadcastEvent("MESleepEvent");


    allobj=find_system(...
    h.daobject.getFullName,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks','On',...
    'LookUnderMasks','all',...
    'FindAll','on');
    daevents.broadcastEvent("MEWakeEvent");
    warning(warn_state);

    get_param(allobj,'Object');
    if~isempty(me)
        me.getRoot.skipAllPropChangeEvents=false;
    end

    h.listeners=...
    {Simulink.listener(h.daobject,'ObjectChildAdded',...
    @(s,e)objectAdded(h,s,e))};
    h.listeners(end+1)=...
    {Simulink.listener(h.daobject,'ObjectChildRemoved',...
    @(s,e)objectRemoved(h,s,e))};
    h.listeners(end+1)=...
    {Simulink.listener(h.daobject,'CloseEvent',...
    @(s,e)locDestroy(h))};
    h.listeners(end+1)=...
    {Simulink.listener(h.daobject,'PostSaveEvent',...
    @(s,e)locFirePropertyChange(h,s,e))};
    h.listeners(end+1)=...
    {Simulink.listener(h.daobject,"SLGraphicalEvent::DIRTY_FLAG_CHANGE_MODEL_EVENT",...
    @(s,e)locFirePropertyChange(h,s,e))};






    if isempty(h.hParent)
        h.listeners(end+1)=...
        {handle.listener(ed,'PropertyChangedEvent',...
        @(s,e)onRootPropChangeEvent(h,s,e))};
    end
end


function locFirePropertyChange(h,~,e)




    if isequal(e.Source,h.daobject)&&~strcmp(e.Source.Name,h.Name)
        locDestroy(h);
    else
        h.fireHierarchyChanged;
        h.firePropertyChange;
    end

end


function locDestroy(h)








    if~isempty(h.hParent)
        assert(isa(h.hParent,'SigLogSelector.MdlRefNode'));
        h.hParent.refModelClosed(h);
        return;
    end


    h.isClosing=true;
    h.listeners=[];



    me=SigLogSelector.getExplorer;
    if~isempty(me)


        isBeingDestroyed=me.closeWarningDlgs;


        locClearTree(me);





        if~isBeingDestroyed
            delete(me);
        else
            me.listeners(end+1)=...
            {handle.listener(me,'MEPostHide',@(s,e)locDestroyME(me,e))};
            me.hide;
        end
    end

end


function locClearTree(me)


    root=me.getRoot;
    root.unpopulate;
    delete(me.imme);

end


function locDestroyME(me,e)%#ok


    delete(me);

end
