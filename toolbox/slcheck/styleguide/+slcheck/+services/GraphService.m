classdef GraphService<handle




    properties(Access=private)
cache_data
bIsValid
    end

    methods(Static)

        function obj=getInstance(varargin)
            persistent uniqueInstance;
            if isempty(uniqueInstance)
                uniqueInstance=slcheck.services.GraphService();
            end
            obj=uniqueInstance;
        end



        function entities=getCanvasSubsystems(top_system,FollowLinks,LookUnderMasks)


            entities=find_system(top_system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',FollowLinks,'LookUnderMasks',LookUnderMasks,'BlockType','SubSystem');
            entities=Advisor.Utils.Simulink.standardFilter(top_system,entities,'Shipping');
            entities=get_param(entities,'handle');
            entities{end+1}=get_param(top_system,'handle');


            entities=entities(cellfun(@(x)~Stateflow.SLUtils.isStateflowBlock(x),entities));


            if strcmp(FollowLinks,'off')


                entities=entities(cellfun(@(x)~isLinked(get_param(x,'object')),entities));
            end
        end

    end

    methods
        function init(this,system,serviceOptions)



            this.reset();

            this.cache_data=containers.Map('KeyType','double','ValueType','any');


            subSys=slcheck.services.GraphService.getCanvasSubsystems(system,serviceOptions.FollowLinks,serviceOptions.LookUnderMasks);



            for i=1:numel(subSys)
                datStrct=[];

                [adjList,myHandles]=Advisor.Utils.Graph.getBlocksOnlyGraphFromSubsystem(subSys{i});
                if isempty(myHandles)
                    continue;
                end

                datStrct.num_nodes=length(adjList);
                datStrct.adjacency=adjList;
                datStrct.handles=myHandles;

                datStrct.predecessors=Advisor.Utils.Graph.getPredecessors(adjList);
                datStrct.successors=Advisor.Utils.Graph.getSuccessors(adjList);

                datStrct.ranks=Advisor.Utils.Graph.calculateRanks(adjList);
                datStrct.in_loop=zeros(1,datStrct.num_nodes);

                [n,cyc]=Advisor.Utils.Graph.findCycles(adjList);
                if n>0
                    for j=1:length(cyc)
                        datStrct.in_loop(cyc{j})=true;
                    end
                end

                this.cache_data(subSys{i})=datStrct;
            end

            this.bIsValid=true;
        end

        function reset(this)
            this.cache_data=[];
            this.bIsValid=false;
        end

        function bValid=isValid(this)
            bValid=this.bIsValid;
        end

        function data=getData(this,canvasH)
            cdata=this.cache_data;
            if cdata.isKey(canvasH)
                data=this.cache_data(canvasH);
            else
                data=[];
            end
        end


    end
end


