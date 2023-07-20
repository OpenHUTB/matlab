classdef ArchitecturePluginTransaction<handle































    properties(GetAccess=public,SetAccess=private)
        ModelName;
    end

    methods
        function obj=ArchitecturePluginTransaction(modelName)




            bdH=get_param(modelName,'Handle');
            subdomain=get_param(modelName,'SimulinkSubDomain');

            if(~strcmpi(subdomain,"Architecture")&&~strcmpi(subdomain,"AUTOSARArchitecture")&&...
                ~strcmpi(subdomain,"SoftwareArchitecture"))
                error('SystemArchitecture:Architecture:InvalidOrDeletedSystemComposerModel',message('SystemArchitecture:Architecture:InvalidOrDeletedSystemComposerModel').getString);
            end

            obj.ModelName=modelName;



            Simulink.SystemArchitecture.internal.ApplicationManager.disableModelConsistencyCheck(bdH);
            systemcomposer.internal.arch.internal.processBatchedPluginEvents(obj.ModelName);
            Simulink.SystemArchitecture.internal.ApplicationManager.incrementArchTxnRefCount(bdH);
            if(Simulink.SystemArchitecture.internal.ApplicationManager.getArchTxnRefCount(bdH)>0)
                systemcomposer.internal.arch.internal.detachSystemComposerPlugin(modelName);
            end
        end

        function delete(obj)



            bdH=get_param(obj.ModelName,'Handle');

            Simulink.SystemArchitecture.internal.ApplicationManager.decrementArchTxnRefCount(bdH);
            if(Simulink.SystemArchitecture.internal.ApplicationManager.getArchTxnRefCount(bdH)==0)
                systemcomposer.internal.arch.internal.processBatchedPluginEvents(obj.ModelName);
                Simulink.SystemArchitecture.internal.ApplicationManager.enableModelConsistencyCheck(bdH);
                systemcomposer.internal.arch.internal.attachSystemComposerPlugin(obj.ModelName);
            end
        end
    end
end


