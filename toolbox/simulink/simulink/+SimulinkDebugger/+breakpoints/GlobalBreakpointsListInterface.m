
classdef GlobalBreakpointsListInterface





    methods(Access=public,Static)

        function isEmptyBpList=isempty(~)
            instance=SimulinkDebugger.breakpoints.GlobalBreakpointsListAccessor.getInstance();
            isEmptyBpList=instance.containsNoBPs();
        end

        function bpList=getBreakpointsInHierarchy(model)


            instance=SimulinkDebugger.breakpoints.GlobalBreakpointsListAccessor.getInstance();
            bpList=instance.getBreakpointsInHierarchy(model);
        end

        function callRefresh()
            instance=SimulinkDebugger.breakpoints.GlobalBreakpointsListAccessor.getInstance();
            instance.callRefresh();
        end

        function openDockedUI()

            editor=SLM3I.SLDomain.findLastActiveEditor();
            studio=editor.getStudio();

            instance=SimulinkDebugger.breakpoints.GlobalBreakpointsListAccessor.getInstance();
            instance.callRefresh();

            ssComp=SimulinkDebugger.breakpoints.BreakpointListSpreadsheet.createSpreadSheetComponent(studio,instance,false);
            SimulinkDebugger.breakpoints.BreakpointListSpreadsheet.moveComponentToDock(ssComp,studio);
        end

        function notifyUIOfModelBreakpointUpdate(bpTypeInt,modelName,isEnabled)


            instance=SimulinkDebugger.breakpoints.GlobalBreakpointsListAccessor.getInstance();
            modelBps=instance.getBreakpointsInHierarchy(modelName).modelBreakpoints;

            bpType=SimulinkDebugger.breakpoints.GlobalBreakpointsListInterface.getBpType(bpTypeInt);
            if~isempty(find([modelBps{:}]==bpTypeInt,1))

                BPID=instance.createModelBPID(modelName,bpType);
                instance.enableDisableModelBreakpointFromCommandLine(BPID,isEnabled);
            elseif isEnabled

                instance.addModelBreakpoint(modelName,bpType,isEnabled);
            end

            instance.callRefresh();
        end

        function updatedInEditor=updatedBpFromEditor(bpTypeIn)


            updatedInEditor=false;
            instance=SimulinkDebugger.breakpoints.GlobalBreakpointsListAccessor.getInstance();
            bpTypeRecentCmds=instance.getBpTypeOfRecentCmds();
            if isempty(bpTypeRecentCmds),return;end

            idxInRecentCmds=find(bpTypeRecentCmds==bpTypeIn,1);
            if~isempty(idxInRecentCmds)
                updatedInEditor=true;
                instance.removeBpTypeOfRecentCmd(idxInRecentCmds);
            end
        end

        function bpType=getBpType(bpTypeInt)


            switch bpTypeInt
            case 1
                bpType=slbreakpoints.datamodel.ModelBreakpointType.ZeroCrossing;
            case 2
                bpType=slbreakpoints.datamodel.ModelBreakpointType.StepSizeLimited;
            case 3
                bpType=slbreakpoints.datamodel.ModelBreakpointType.SolverError;
            case 4
                bpType=slbreakpoints.datamodel.ModelBreakpointType.NanValues;
            otherwise

                assert(false);
            end
        end
    end
end
