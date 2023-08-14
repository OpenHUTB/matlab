function sourceLocation=userSourceLocation(sid)




    lm=Simulink.report.HTMLLinkManager;
    sourceLocation=lm.getLinkToFrontEnd(sid);




    if(isempty(sourceLocation)||(~contains(string(sourceLocation),":"))||(sourceLocation(1)==':'))
        return;
    end


    if~designcostestimation.internal.util.isFunctionOnPath(sourceLocation)


        blkHandle=Simulink.ID.getHandle(sid);
        if(contains(string(class(blkHandle)),"Stateflow"))
            sourceLocation=blkHandle.Chart.getFullName;
        end
    end
end
