







classdef DebugContext<handle

    properties(Access=private)
        debugMdl=[];

        simInRevertTempState=[];
        preInitTempState=[];


        modelRefs=[];
        activeEditor=[];
        stepSize=[];
    end

    properties(Access=public)
        curObjId=[];
        curBlkSid=[];
    end


    methods(Access=public)
        function obj=DebugContext(model)
            obj.debugMdl=model;
            if~exist(model)
                return;
            end


            obj.modelRefs=find_mdlrefs(model,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
        end

        revertSimulationInput(obj);
        rehighlightMdlIfHighlightedBefore(obj);
        simIn=turnOffDiagnostics(obj,simIn);
        preInitModelSetup(obj);
        loadSimInputValues(obj,simInputValues,stopTime);

        function stepSize=getStepSize(obj)
            stepSize=obj.stepSize;
        end

        function setStepSize(obj,stepSize)
            obj.stepSize=stepSize;
        end

        function tmpState=getSimInRevertTempState(obj)
            tmpState=obj.simInRevertTempState;
        end

        function setSimInRevertTempState(obj,state)
            obj.simInRevertTempState=state;
        end

        function disableDirtyFlagForAllModels(obj)
            for i=1:numel(obj.modelRefs)
                set_param(obj.modelRefs{i},'dirty','off');
            end
        end


        function showNotificationInActiveEditor(obj,msgId,msgstr)
            editor=SlicerConfiguration.findEditor(obj.debugMdl);
            editor.deliverInfoNotification(msgId,msgstr);
            obj.activeEditor=editor;
        end


        function clearEditorNotification(obj)
            if~isempty(obj.activeEditor)&&isvalid(obj.activeEditor)
                obj.activeEditor.closeNotificationByMsgID('Sldv:DebugUsingSlicer:BannerMessageOnSetupComplete');
            end
        end

        function delete(obj)
            obj.debugMdl=[];
            obj.curObjId=[];
            obj.curBlkSid=[];
            obj.simInRevertTempState=[];
            obj.modelRefs=[];
            obj.activeEditor=[];
            obj.preInitTempState=[];
        end

        function revertDiagnosticSimulationInput(obj)

            if~isempty(obj.preInitTempState)&&isvalid(obj.preInitTempState)

                if bdIsLoaded(obj.debugMdl)&&...
                    ~strcmp(get_param(obj.debugMdl,'SimulationStatus'),'paused')

                    delete(obj.preInitTempState);
                end
            end
        end
    end
end