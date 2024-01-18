function handle=getHandleFromFullSID(sid,getSFId)

    if nargin<2
        getSFId=false;
    end
    handle=slreq.internal.slutils.getSLHandleFromSID(sid);

    if handle==-1
        if~isempty(Simulink.ID.checkSyntax(sid))
            return;
        end

        if~isBdLoaded(sid)
            return;
        end

        handle=getSFObjFromSID(sid,getSFId);
    end
end


function out=isBdLoaded(sid)
    bdname=strtok(sid,':');
    out=dig.isProductInstalled('Simulink')&&bdIsLoaded(bdname);
end


function handle=getSFObjFromSID(sid,getSFId)
    handle=-1;
    [out,remainder]=Simulink.SIDSpace.getHandle(sid);
    if~isempty(remainder)
        chartId=sfprivate('block2chart',out);
        activeInstance=sfprivate('getActiveInstance',chartId);

        if~isequal(activeInstance,out)
            sfprivate('setActiveInstance',chartId,...
            out);
        end

        handle=sfprivate('ssIdToHandle',[':',remainder],out);
        if isempty(handle)
            handle=-1;
        end

        if getSFId
            handle=handle.Id;
        end
    end
end
