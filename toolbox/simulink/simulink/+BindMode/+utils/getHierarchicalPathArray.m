

function hierarchicalPathArray=getHierarchicalPathArray(localBlockPath,varargin)


    if(nargin==2)

        includePipedPath=varargin{1};
    else
        includePipedPath=false;
    end
    blockHandle=get_param(localBlockPath,'Handle');
    parentHandle=get_param(get_param(blockHandle,'Parent'),'Handle');
    activeEditor=SLM3I.SLDomain.getLastActiveEditorFor(parentHandle);
    if(isempty(activeEditor))
        blockPathObj=Simulink.BlockPath(localBlockPath);
    else
        blockPathObj=Simulink.BlockPath.fromHierarchyIdAndHandle(activeEditor.getHierarchyId,blockHandle);
    end
    hierarchicalPathArray=blockPathObj.convertToCell();
    if(includePipedPath)
        pipePath=blockPathObj.toPipePath();
        hierarchicalPathArray=[pipePath;hierarchicalPathArray];
    end
end