




classdef BreakpointList<Simulink.Debug.BaseItemList
    properties(Access=private)
        viewer=[];
    end

    methods(Static)
        function out=getInstance(reset)%#ok<INUSD>
mlock
            persistent instance
            if isempty(instance)
                instance=Simulink.Debug.BreakpointList();
            end
            out=instance;
            if exist('reset','var')
                instance=[];
            end
        end

        function addBreakpointToList(bp)
            instance=Simulink.Debug.BreakpointList.getInstance();
            instance.addItemToList(bp);
        end

        function removeBreakpointFromList(bp)
            instance=Simulink.Debug.BreakpointList.getInstance();
            instance.removeItemFromList(bp);
        end

        function runToCursorBreakpoint=getRunToCursorBreakpointFromList()
            instance=Simulink.Debug.BreakpointList.getInstance();
            breakpointList=instance.getAllItems();
            for index=1:length(breakpointList)
                if isprop(breakpointList{index},'tag')&&strcmp(breakpointList{index}.tag,'RunToCursorStmt')
                    runToCursorBreakpoint=breakpointList{index};
                    return;
                end
            end
            runToCursorBreakpoint=[];
        end

        function bpList=getAllBreakpoints()
            instance=Simulink.Debug.BreakpointList.getInstance();
            bpList=instance.getAllItems();
        end

        function listFilter=getShownInBreakpointDialogFilter()
            breakpointList=Simulink.Debug.BreakpointList.getAllBreakpoints();
            listFilter=cellfun(@(bp)bp.shouldShowInBreakpointDialog,breakpointList);
        end

        function bpInDialogList=getShownInBreakpointDialogBreakpoints()




            import Simulink.Debug.*
            bpList=BreakpointList.getAllBreakpoints();
            listFilter=BreakpointList.getShownInBreakpointDialogFilter();
            bpInDialogList=bpList(listFilter);
        end

        function activeBpList=getActiveBreakpoints()
            instance=Simulink.Debug.BreakpointList.getInstance();
            activeBpList=instance.getActiveItems();
        end

        function bp=getBreakpointWithId(id)
            bpList=Simulink.Debug.BreakpointList.getAllBreakpoints();
            bp=[];

            for i=1:numel(bpList)
                if bpList{i}.id==id
                    bp=bpList{i};
                    return;
                end
            end
        end

        function reset()
            instance=Simulink.Debug.BreakpointList.getInstance('reset');
            instance.resetImpl();
        end

        function notifyInstanceOfModelLoadEvent(modelName)
            instance=Simulink.Debug.BreakpointList.getInstance();
            instance.reactToModelLoad(modelName);
        end

        function notifyInstanceOfModelCloseEvent(modelName)
            instance=Simulink.Debug.BreakpointList.getInstance();
            instance.reactToModelClose(modelName);
        end

        function toggleEnablednessForBreakpoints(shouldEnable)
            bpList=Simulink.Debug.BreakpointList.getShownInBreakpointDialogBreakpoints();
            for i=1:numel(bpList)
                bp=bpList{i};
                if shouldEnable
                    bp.enable();
                else
                    bp.disable();
                end
            end
        end

        function exportBreakpointsToMATFile(matFilePath)
            breakpointList=Simulink.Debug.BreakpointList.getShownInBreakpointDialogBreakpoints();

            if exist(matFilePath,'file')
                save(matFilePath,'breakpointList','-append');
            else
                save(matFilePath,'breakpointList');
            end
        end

        function importBreakpointsFromMATFile(matFilePath)
            import Simulink.Debug.*;
            listFilter=BreakpointList.getShownInBreakpointDialogFilter();
            BreakpointList.deleteAllBreakpointsWithFilter(listFilter);

            instance=BreakpointList.getInstance();

            matFileContents=load(matFilePath);



            instance.loadItems(matFileContents.breakpointList);
        end

        function deleteAllBreakpointsWithFilter(listFilter)
            instance=Simulink.Debug.BreakpointList.getInstance();
            instance.deleteAllItems(listFilter);
        end

        function deleteAllBreakpoints()
            instance=Simulink.Debug.BreakpointList.getInstance();
            instance.deleteAllItems();
        end
    end
end
