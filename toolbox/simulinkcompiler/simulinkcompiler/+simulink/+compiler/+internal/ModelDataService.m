classdef ModelDataService




    properties
ModelName
    end

    properties(Access=private)
RootInternalBlockPathsCache
RootScopeBlockPathsCache

RootOutportsCache
RootOutportNamesCache

RootInternalSignalSourcesCache
NumRootInternalSignalsCache
    end

    methods


        function obj=ModelDataService(modelName)
            obj.ModelName=modelName;
            load_system(obj.ModelName);
        end



        function outports=getRootOutports(obj)
            if~isempty(obj.RootOutportsCache)
                outports=obj.RootOutportsCache;
                return;
            end

            obj.RootOutportsCache=find_system(obj.ModelName,...
            'LookUnderMasks','off',...
            'FollowLinks','off',...
            'SearchDepth',1,...
            'FindAll','on',...
            'BlockType','Outport');
            outports=obj.RootOutportsCache;
        end



        function outportNames=getRootOutPortNames(obj)
            if~isempty(obj.RootOutportNamesCache)
                outportNames=obj.RootOutportNamesCache;
                return;
            end

            ports=obj.getRootOutports();
            obj.RootOutportNamesCache=arrayfun(@(port)get_param(port,'Name'),...
            ports,'UniformOutput',false);
            outportNames=obj.RootOutportNamesCache;
        end



        function blockPaths=getRootInternalBlockPaths(obj)
            if~isempty(obj.RootInternalBlockPathsCache)
                blockPaths=obj.RootInternalBlockPathsCache;
                return;
            end

            obj.RootInternalBlockPathsCache=find_system(obj.ModelName,...
            'SearchDepth',1,...
            'MatchFilter',@internalBlocks);
            blockPaths=obj.RootInternalBlockPathsCache;
        end



        function numPorts=getNumRootInternalSignals(obj)
            if~isempty(obj.NumRootInternalSignalsCache)
                numPorts=obj.NumRootInternalSignalsCache;
                return;
            end

            pathToPortCountMap=...
            obj.getRootInternalBlockPathsToOutportCountsMap();

            obj.NumRootInternalSignalsCache=...
            sum(cell2mat(pathToPortCountMap.values));

            numPorts=obj.NumRootInternalSignalsCache;
        end



        function blockPaths=getRootScopeBlockPaths(obj)
            if~isempty(obj.RootScopeBlockPathsCache)
                blockPaths=obj.RootScopeBlockPathsCache;
                return;
            end

            obj.RootScopeBlockPathsCache=find_system(obj.ModelName,...
            'SearchDepth',1,...
            'BlockType','Scope');
            blockPaths=obj.RootScopeBlockPathsCache;
        end



        function TF=modelHasScopes(obj)
            numScopes=numel(obj.getRootScopeBlockPaths());
            TF=numScopes>0;
        end



    end

    methods(Access=private)

        function map=getRootInternalBlockPathsToOutportCountsMap(obj)
            blockPaths=obj.getRootInternalBlockPaths();
            map=containers.Map;

            for blockPath=blockPaths'
                portHandles=get_param(blockPath{1},'PortHandles');

                if isfield(portHandles(1),'Outport')
                    numOutPorts=numel(portHandles(1).Outport);
                    map(blockPath{1})=numOutPorts;
                end
            end
        end

    end

end

function match=internalBlocks(handle)
    match=true;

    if isequal(get_param(handle,'Type'),'block_diagram')
        match=false;
        return;
    end

    if isequal(get_param(handle,'Type'),'block')
        blockType=get_param(handle,'BlockType');

        if isequal(blockType,'Inport')||...
            isequal(blockType,'Outport')||...
            isequal(blockType,'Scope')

            match=false;
        end
    end
end
