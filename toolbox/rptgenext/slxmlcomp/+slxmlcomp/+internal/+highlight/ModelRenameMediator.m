classdef ModelRenameMediator<handle





    properties(SetAccess=private,GetAccess=public)
ListenerCollection
Disposables
SimulinkRootCallbackId
PostNameChangeCallbackId
CleanUpRootListenerOnDelete
    end

    methods(Access=public,Static)
        function toReturn=getInstance()
            mlock;
            persistent instance
            if isempty(instance)






                instance=slxmlcomp.internal.highlight.ModelRenameMediator("root",false);





                instance.listenToModelCreateEvents();
            end
            toReturn=instance;
        end
    end

    methods(Access=public,Static)
        function obj=newInstance(mediatorId)
            import slxmlcomp.internal.highlight.ModelRenameMediator
            obj=ModelRenameMediator(mediatorId,true);
            obj.listenToModelCreateEvents();
        end
    end

    methods(Access=public)

        function fireListeners(obj,modelName,newName)
            obj.ListenerCollection.fireListeners(modelName,newName);
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
            @(modelName)obj.addNameChangeListener(modelName)...
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
        function obj=ModelRenameMediator(...
            mediatorId,...
cleanupRootListenerOnDelete...
            )
            obj.ListenerCollection=slxmlcomp.internal.highlight.ListenerCollection;
            obj.CleanUpRootListenerOnDelete=cleanupRootListenerOnDelete;

            obj.SimulinkRootCallbackId="slDiffHighlightRename"+mediatorId;
            obj.PostNameChangeCallbackId="slDiffHighlightRename"+mediatorId;
        end

        function addNameChangeListener(obj,modelName)
            handle=get_param(modelName,'handle');
            function fireNameChangeListeners()
                currentHandle=get_param(bdroot,'Handle');
                newName=get_param(currentHandle,'Name');

                if handle==currentHandle
                    origName=modelName;
                    obj.fireListeners(origName,newName);

                else




                end



                Simulink.removeBlockDiagramCallback(...
                currentHandle,...
                'PostNameChange',...
                obj.PostNameChangeCallbackId...
                );
                obj.addNameChangeListener(newName);
            end

            Simulink.addBlockDiagramCallback(...
            modelName,...
            'PostNameChange',...
            obj.PostNameChangeCallbackId,...
            @fireNameChangeListeners...
            );
        end
    end

end
