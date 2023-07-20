function result=isZCPort(portHandle,modelName)


    if nargin<2
        modelName='';
    end

    result=false;
    zcPort=[];

    if~isempty(modelName)
        try
            modelName=bdroot(modelName);
        catch
            return;
        end
    end

    if~isempty(modelName)&&~Simulink.internal.isArchitectureModel(modelName)
        return;
    end

    try
        if ischar(portHandle)
            zcPort=sysarch.resolveZCElement(portHandle,modelName);
        elseif isnumeric(portHandle)
            try
                bdH=bdroot(portHandle(1));
            catch
                return;
            end

            if Simulink.internal.isArchitectureModel(bdH)
                zcPort=systemcomposer.utils.getArchitecturePeer(portHandle(1));
            end
        else
            zcPort=portHandle;
        end
    catch
        zcPort=[];
    end

    result=~isempty(zcPort)&&(isa(zcPort,'systemcomposer.architecture.model.design.Port')||...
    isa(zcPort,'systemcomposer.architecture.model.views.ComponentOccurPort'));

end
