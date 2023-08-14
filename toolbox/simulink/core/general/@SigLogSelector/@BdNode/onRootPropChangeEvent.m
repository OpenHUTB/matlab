function wasProcessed=onRootPropChangeEvent(h,s,e)














    wasProcessed=false;
    actualSrc=e.Source;
    if isa(e.Source,'DAStudio.DAObjectProxy')

        actualSrc=e.Source.getMCOSObjectReference;
    end
    if h.skipAllPropChangeEvents
        return;
    elseif~isa(actualSrc,'Simulink.ModelReference')&&...
        ~isa(actualSrc,'Simulink.SubSystem')&&...
        ~isa(actualSrc,'Stateflow.State')&&...
        ~isa(actualSrc,'Stateflow.Data')&&...
        ~isa(actualSrc,'Stateflow.Box')&&...
        ~isa(actualSrc,'Stateflow.Function')&&...
        ~isa(actualSrc,'Stateflow.TruthTable')&&...
        ~isa(actualSrc,'Simulink.Line')
        return;
    end



    if isa(actualSrc,'Simulink.Line')

        if isequal(h.delayCallback,true)
            h.lastTimestamp=clock;
            return;
        end

        locDelay=h.addTimestampDeltaToQueue();
        if locDelay<1
            h.delayCallback=true;
            h.callbackTimer=timer;
            h.callbackTimer.StartDelay=1;
            h.callbackTimer.TimerFcn=@locTimedCallback;
            h.callbackTimer.StopFcn=@locTimerCleanup;
            start(h.callbackTimer);
            h.lastTimestamp=clock;




            me=SigLogSelector.getExplorer;
            me.imme.loadListViewContent;
            return;
        end
    end





    wasProcessed=locRecursiveProcessEvent(h,s,e);




    if~wasProcessed&&isa(actualSrc,'Simulink.ModelReference')&&...
        strcmpi(actualSrc.ProtectedModel,'off')
        h.addUnprotectedModel(actualSrc);
        return;
    end



    h.lastTimestamp=clock;

end


function wasProcessed=locRecursiveProcessEvent(h,s,e)





    wasProcessed=h.onPropChangeEvent(s,e);


    if~isempty(h.childNodes)
        numChildren=h.childNodes.getCount();
        for chIdx=1:numChildren
            child=h.childNodes.getDataByIndex(chIdx);
            childProcessed=locRecursiveProcessEvent(child,s,e);
            if childProcessed
                wasProcessed=true;
            end
        end
    end

end


function locTimedCallback(~,~)
    me=SigLogSelector.getExplorer;
    if~isequal(me,[])
        rt=me.getRoot;
        if~isequal(rt,[])

            rt.delayCallback=false;
            rt.refreshSignals(false);
        end
    end
end


function locTimerCleanup(mtimer,~)
    delete(mtimer);
end
