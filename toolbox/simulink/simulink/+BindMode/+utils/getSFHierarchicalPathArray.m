

function hierarchicalPathArray=getSFHierarchicalPathArray(localBlockPath,varargin)


    includePipedPath=false;
    if(nargin==2)

        includePipedPath=varargin{1};
    end
    activeEditor=BindMode.utils.getLastActiveEditor();
    if(isempty(activeEditor))
        hierarchicalPathArray={localBlockPath};
    else
        hid=activeEditor.getHierarchyId();
        hierarchicalPathArray=GLUE2.HierarchyService.getPaths(hid);
        hierarchicalPathArray{end}=localBlockPath;
    end
    if(includePipedPath)
        blockPath=Simulink.BlockPath(hierarchicalPathArray);
        pipePath=blockPath.toPipePath();
        hierarchicalPathArray=[pipePath;hierarchicalPathArray];
    end
end