function out=getSLType(artifact,id)



    if ishandle(artifact)
        objH=artifact;
    else

        [~,rootname]=fileparts(artifact);
        if~rmisl.isSimulinkModelLoaded(rootname)
            out='unresolved-item';
            return;
        end
        sid=[rootname,id];
        if contains(sid,'.')
            out='simulink-block';
            return;
        end

        if rmisl.isHarnessIdString(sid)
            [~,objH]=rmisl.resolveObjInHarness(sid);
            if isempty(objH)
                out='unresolved-item';
                return;
            end

        elseif sysarch.isZCElement(id)

            try
                zcObj=sysarch.resolveZCElement(id,rootname);
            catch ex
                if strcmpi(ex.identifier,'Simulink:Commands:CannotOpenDuringClose')




                    out='unresolved-item';
                    return;
                else

                    rethrow(ex)
                end

            end
            if sysarch.isZCPort(zcObj)
                portActions=zcObj.getPortAction;
                if strcmpi(portActions,'PHYSICAL')
                    out='systemcomposer-physical-port';
                else
                    out='systemcomposer-port';
                end
            else
                out='simulink-component';
            end
            return;
        elseif rmifa.isFaultIdString(sid)
            faultInfoObj=rmifa.getFaultInfoObj(rootname,sid);
            if isa(faultInfoObj,'Simulink.fault.Fault')
                out='faultanalyzer-fault';
            else
                out='faultanalyzer-conditional';
            end
            return;
        else
            try
                objH=Simulink.ID.getHandle(sid);
            catch ex %#ok<NASGU>
                out='unresolved-item';
                return;
            end
        end

    end


    slobj=objH;
    if isa(objH,'double')
        if sysarch.isComponent(objH)
            if strcmp(get_param(objH,'type'),'block_diagram')
                out='systemcomposer-model';
            else

                if strcmpi(get_param(objH,'blocktype'),'subsystem')
                    if strcmpi(slreq.utils.getSLTypeByObj(get(objH,'Object')),'simulink-chart')
                        out='simulink-chart';
                        return
                    end

                end
                out='simulink-component';
            end
            return;
        end

        if sysarch.isZCPort(objH)
            out='systemcomposer-port';
            return;
        end
        try

            objH=slreq.utils.getRMISLTarget(objH,true);
            slobj=get(objH,'Object');
        catch ME %#ok<NASGU>


            slobj=idToHandle(sfroot,objH);
        end
    end

    out=slreq.utils.getSLTypeByObj(slobj);

end