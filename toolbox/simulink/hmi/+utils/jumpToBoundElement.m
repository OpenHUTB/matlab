function jumpToBoundElement(editor,element,varargin)


    modelHandle=editor.blockDiagramHandle;
    isSubsystem=false;
    if(nargin>=3)
        isSubsystem=varargin{1};
    end
    if(isa(element,'StateflowDI.State'))
        elemHandleOrId=double(element.backendId);
        elemDomain='stateflow';
    else
        elemHandleOrId=element.handle;
        elemDomain='simulink';
    end
    if(isSubsystem)
        [boundHandleOrId,boundDomain]=Simulink.HMI.getBoundElementInSubsystem(...
        modelHandle,elemHandleOrId,elemDomain);
    else
        [boundHandleOrId,boundDomain]=Simulink.HMI.getDefaultBoundElement(...
        modelHandle,elemHandleOrId,elemDomain);
    end


    if(boundHandleOrId==-1)
        modelHandle=editor.getStudio.App.blockDiagramHandle;
        [boundHandleOrId,boundDomain]=Simulink.HMI.getDefaultBoundElement(...
        modelHandle,elemHandleOrId,elemDomain);
    end


    if(strcmp(boundDomain,'stateflow'))

        obj=sf('IdToHandle',boundHandleOrId);
        isData=false;
        if(isa(obj,'Stateflow.Chart'))
            obj.view();
        elseif(isa(obj,'Stateflow.Data'))
            chartId=sfprivate('getChartOf',obj.Id);
            chartObj=sf('IdToHandle',chartId);
            chartObj.view();
            isData=true;
        else
            obj.Subviewer.view();
        end
        if isData

            utils.toggleHighlightForSFData(obj.Id,true);
        else
            Simulink.HMI.highlightElement(modelHandle,boundHandleOrId,boundDomain);
        end
    else

        if(strcmp(get_param(boundHandleOrId,'Type'),'line'))
            targetElemHandle=get_param(boundHandleOrId,'SrcBlockHandle');
        else
            targetElemHandle=boundHandleOrId;
        end
        blockPath=Simulink.BlockPath(getfullname(targetElemHandle));



        if(strcmp(elemDomain,'stateflow'))
            obj=sf('IdToHandle',elemHandleOrId);
            elemHandleOrId=sfprivate('chart2block',obj.Chart.Id);
        end
        elemBlockPath=Simulink.BlockPath.fromHierarchyIdAndHandle(...
        editor.getHierarchyId,elemHandleOrId);
        if(elemBlockPath.getLength>1)

            blockPathCells=elemBlockPath.convertToCell;
            blockPathCells{end}=blockPath.getBlock(1);
            blockPath=Simulink.BlockPath(blockPathCells);
        end

        Simulink.HMI.clearBindingHighlight(modelHandle);
        utils.hiliteAndFade_system(boundHandleOrId,modelHandle,blockPath);
    end
end
