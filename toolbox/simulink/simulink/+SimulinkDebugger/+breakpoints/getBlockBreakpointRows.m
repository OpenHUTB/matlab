function[children,breakpointIdx]=getBlockBreakpointRows(globalBreakpoints,studio,hitCountMap,children,breakpointIdx)











    blockBreakpointsMap=globalBreakpoints.blockBreakpoints;
    editors=studio.App.getAllEditors();
    for key=blockBreakpointsMap.keys
        bp=blockBreakpointsMap{key{1}};
        if~bdIsLoaded(bp.modelName)

            continue;
        end
        if~isempty(studio)
            blockPath=strrep(bp.blockPath,'''','');
            blockHandle=get_param(blockPath,'Handle');
            parentMdl=get_param(blockHandle,'Parent');


            parentEditor=[];
            for kdx=1:numel(editors)
                if isequal(editors(kdx).getName,parentMdl)
                    parentEditor=editors(kdx);
                    break;
                end
            end


            if~isempty(parentEditor)
                fullBlockPathToTopModel=Simulink.BlockPath.fromHierarchyIdAndHandle(...
                parentEditor.getHierarchyId,blockHandle);
            else

                break;
            end
        end

        if isequal(get_param(bp.modelName,'SimulationStatus'),'stopped')
            hitCount=0;
        elseif hitCountMap.isKey(bp.BPID)
            hitCount=hitCountMap(bp.BPID);
        else
            hitCount=0;
            hitCountMap(bp.BPID)=hitCount;
        end

        blockbp=SimulinkDebugger.breakpoints.BlockBreakpoint(...
        breakpointIdx,bp,fullBlockPathToTopModel,hitCount);
        childObj=SimulinkDebugger.breakpoints.BreakpointListSpreadsheetBlockRow(blockbp);
        children=[children,childObj];%#ok<AGROW>
        breakpointIdx=breakpointIdx+1;
    end
end
