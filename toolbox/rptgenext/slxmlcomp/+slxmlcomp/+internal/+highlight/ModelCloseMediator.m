classdef ModelCloseMediator<handle





    properties(SetAccess=private,GetAccess=public)
ListenerCollection
Disposables
SimulinkRootCallbackId
CloseCallbackId
CleanUpRootListenerOnDelete
    end

    methods(Access=public,Static)
        function toReturn=getInstance()
            mlock;
            persistent instance
            if isempty(instance)






                instance=slxmlcomp.internal.highlight.ModelCloseMediator("root",false);






                instance.listenToModelCreateEvents();
            end
            toReturn=instance;
        end
    end

    methods(Access=public,Static)





        function obj=newInstanceForPersistent(mediatorId)
            import slxmlcomp.internal.highlight.ModelCloseMediator
            obj=ModelCloseMediator(mediatorId,false);
            obj.listenToModelCreateEvents();
        end

        function obj=newInstance(mediatorId)
            import slxmlcomp.internal.highlight.ModelCloseMediator
            obj=ModelCloseMediator(mediatorId,true);
            obj.listenToModelCreateEvents();
        end
    end

    methods(Access=public)

        function fireListeners(obj,modelName)
            obj.ListenerCollection.fireListeners(modelName);
        end

        function listenerCleanup=addListener(obj,modelName,listener)
            listenerCleanup=obj.ListenerCollection.addListener(modelName,listener);
        end

        function removeListener(obj,modelName,toRemove)
            obj.ListenerCollection.removeListener(modelName,toRemove);
        end

        function listenToModelCreateEvents(obj)
            Simulink.addRootPostCreateCallback(...
            obj.SimulinkRootCallbackId,...
            @(modelName)obj.addModelCloseListener(modelName)...
            );

            if obj.CleanUpRootListenerOnDelete
                rootCallbackId=obj.SimulinkRootCallbackId;
                obj.Disposables{end+1}=onCleanup(...
                @()Simulink.removeRootPostCreateCallback(rootCallbackId)...
                );
            end
        end

    end

    methods(Access=private)
        function obj=ModelCloseMediator(...
            mediatorId,...
cleanupRootListenerOnDelete...
            )
            obj.ListenerCollection=slxmlcomp.internal.highlight.ListenerCollection;
            obj.CleanUpRootListenerOnDelete=cleanupRootListenerOnDelete;

            obj.SimulinkRootCallbackId="slDiffHighlightClose"+mediatorId;
            obj.CloseCallbackId="slDiffHighlightClose"+mediatorId;
        end

        function addModelCloseListener(obj,modelName)
            function firePreCloseListeners()


                obj.fireListeners(...
                get_param(bdroot,'Name')...
                );
            end

            Simulink.addBlockDiagramCallback(...
            modelName,...
            'PreClose',...
            obj.CloseCallbackId,...
            @firePreCloseListeners...
            );
        end
    end

end
