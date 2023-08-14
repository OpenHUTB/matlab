classdef SimulinkHandler<handle




    properties(GetAccess=public,SetAccess=immutable)
        Analyzers;
        Resolver;
        ModelInfo;
        BaseWorkspace;
        ModelWorkspace;
        MachineWorkspace;
    end

    properties(GetAccess=private,SetAccess=immutable)
        Delegate;
        Workspaces;
        SFWorkspaces;
    end

    properties(Access=private)
        SIDMap containers.Map
        PathToSIDMap containers.Map
        StateflowChartMap containers.Map
        StateflowParentMap containers.Map
    end

    methods

        function this=SimulinkHandler(delegate,file,root)
            this.Delegate=delegate;
            this.Analyzers=delegate.Analyzers;
            this.Resolver=delegate.Resolver;

            info=Simulink.MDLInfo(file);
            this.ModelInfo.BlockDiagramName=root;
            this.ModelInfo.IsSLX=dependencies.internal.analysis.simulink.hasSlxQueries(file);
            this.ModelInfo.IsLibrary=info.IsLibrary;
            this.ModelInfo.ResavedPath=file;

            [~,~,ext]=fileparts(file);
            this.ModelInfo.SimulinkVersion=simulink_version(info.SimulinkVersion);
            if~this.ModelInfo.SimulinkVersion.valid&&strcmp(ext,'.sfx')
                this.ModelInfo.SimulinkVersion=simulink_version;
            end
            this.ModelInfo.IsValid=~isempty(info.BlockDiagramType);

            this.BaseWorkspace=delegate.Analyzers.MATLAB.BaseWorkspace;

            this.Workspaces=containers.Map;
            this.Workspaces('')=this.BaseWorkspace;
            this.ModelWorkspace=this.getWorkspace(root);
            this.ModelWorkspace.Scope=dependencies.internal.analysis.matlab.Scope.File;

            this.MachineWorkspace=dependencies.internal.analysis.matlab.Workspace;
            this.MachineWorkspace.Scope=dependencies.internal.analysis.matlab.Scope.File;
            this.SFWorkspaces=containers.Map;
            this.SFWorkspaces('')=this.MachineWorkspace;

            this.SIDMap=containers.Map('KeyType','char','ValueType','char');
            this.PathToSIDMap=containers.Map('KeyType','char','ValueType','char');
            this.StateflowChartMap=containers.Map('KeyType','char','ValueType','char');
            this.StateflowParentMap=containers.Map('KeyType','char','ValueType','char');
        end

        function workspace=getWorkspace(this,block)
            if~this.Workspaces.isKey(block)
                pBlock=i_getParent(block);
                pWorkspace=this.getWorkspace(pBlock);
                this.Workspaces(block)=dependencies.internal.analysis.matlab.Workspace.createChildWorkspace(pWorkspace,"");
            end
            workspace=this.Workspaces(block);
        end

        function workspace=getMaskedWorkspace(this,block)
            workspace=this.getWorkspace(block);
            while workspace.Scope~=dependencies.internal.analysis.matlab.Scope.Mask&&~isempty(workspace.Parent)
                workspace=workspace.Parent;
            end
        end

        function path=getPath(this,sid)
            if this.SIDMap.isKey(sid)
                path=this.SIDMap(sid);
            else
                path=sid;
            end
        end

        function sid=getSID(this,path)
            if this.PathToSIDMap.isKey(path)
                sid=this.PathToSIDMap(path);
            else
                sid="";
            end
        end

        function workspace=getStateflowWorkspace(this,id)
            if~this.SFWorkspaces.isKey(id)
                pID=this.getStateflowParent(id);
                pWorkspace=this.getStateflowWorkspace(pID);
                this.SFWorkspaces(id)=dependencies.internal.analysis.matlab.Workspace.createChildWorkspace(pWorkspace,"");
            end
            workspace=this.SFWorkspaces(id);
        end

        function name=getStateflowChartName(this,id)
            if this.StateflowChartMap.isKey(id)
                name=string(this.StateflowChartMap(id));
            else
                name=this.ModelInfo.BlockDiagramName;
            end
        end

        function id=getStateflowParent(this,id)
            if this.StateflowParentMap.isKey(id)
                id=string(this.StateflowParentMap(id));
            else
                id="";
            end
        end

        function warning(this,warning)
            this.Delegate.warning(warning);
        end

        function error(this,exception)
            this.Delegate.error(exception);
        end

    end

    methods(Hidden=true)
        function setSIDMap(this,map)
            this.SIDMap=map;
        end

        function setPathToSIDMap(this,map)
            this.PathToSIDMap=map;
        end

        function sids=getKnownSIDs(this)
            sids=this.SIDMap.keys;
        end

        function setStateflowInfo(this,chartMap,parentMap)
            this.StateflowChartMap=chartMap;
            this.StateflowParentMap=parentMap;
        end
    end

end


function parent=i_getParent(block)
    idx=strfind(block,'/');
    if isempty(idx)
        parent='';
    else
        parent=block(1:idx(end)-1);
    end
end
