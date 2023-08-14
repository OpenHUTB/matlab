function topMdlH=getTopModelFromObj(obj)





    topMdlH=-1;

    if rmifa.isFaultInfoObj(obj)
        faultInfoObj=rmifa.resolveObjInFaultInfo(obj);
        topMdl=faultInfoObj.getTopModelName();
        topMdlH=get_param(topMdl,'handle');
        return;
    end

    className=class(obj);
    objH=-1;
    if startsWith(className,'Simulink.')
        if isa(obj,'Simulink.BlockDiagram')||isa(obj,'Simulink.Block')||isa(obj,'Simulink.Annotation')
            objH=obj.handle;
        elseif isa(obj,'Simulink.DDEAdapter')
            objH=gcbh;
        end

    elseif startsWith(className,'Stateflow.')
        if any(strcmp(className,rmisf.sfisa('supportedTypes')))
            objH=get_param(obj.Chart.Path,'handle');
        end

    elseif isa(obj,'double')
        if isscalar(obj)
            objH=obj;
        end
    end

    if objH==-1

        return;
    end

    topMdlH=rmifa.getTopModelFromModelElement(objH);
end