classdef ModelLayoutChecker<handle




    properties
system
mHandles
mInLoop
allSubSys
    end

    methods

        function obj=ModelLayoutChecker(system)
            obj.system=system;
        end

        function init(this)

            this.getAllCheckableSubsystems();


            this.doLoops();
        end

        function failures=check(this)

            flags=true(1,numel(this.allSubSys));
            for i=1:numel(this.allSubSys)
                flags(i)=this.checkOne(this.allSubSys{i});
            end

            failures=this.allSubSys(~flags);

        end

        function bResult=checkOne(this,inSys)
            bResult=true;

            [adjList,myHandles]=Advisor.Utils.Graph.getBlocksOnlyGraphFromSubsystem(inSys);

            mNumNodes=length(adjList);
            if mNumNodes==0
                return;
            end


            mPredecessors=Advisor.Utils.Graph.getPredecessors(adjList);
            mSuccessors=Advisor.Utils.Graph.getSuccessors(adjList);


            mRanks=this.calculateRanks(adjList,mNumNodes,mPredecessors,mSuccessors);

            if mNumNodes==0
                bResult=true;
                return;
            end



            bResult=this.isOrientedRight(mNumNodes,myHandles);
            if~bResult
                return;
            end


            bResult=this.areBlocksSequentialPlaced(adjList,mNumNodes,myHandles,mRanks);
            if~bResult
                return;
            end


            bResult=this.areBlocksParallelPlaced(adjList,mNumNodes,myHandles,mRanks);
            if~bResult
                return;
            end

        end

        function allSubSys=getAllCheckableSubsystems(this)
            mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(this.system);
            inputParams=mdlAdvObj.getInputParameters;


            this.mHandles=find_system(get_param(this.system,'handle'),...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'FollowLinks',inputParams{1}.Value,...
            'LookUnderMasks',inputParams{2}.Value,...
            'Type','Block');

            allSubSys=find_system(this.system,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'FollowLinks',inputParams{1}.Value,...
            'LookUnderMasks',inputParams{2}.Value,...
            'BlockType','SubSystem','MaskType','');
            allSubSys{end+1}=this.system;

            allSubSys=unique(allSubSys);


            allSubSys=allSubSys(cellfun(@(x)~Stateflow.SLUtils.isStateflowBlock(x),allSubSys));

            if strcmp(inputParams{1}.Value,'off')


                allSubSys=allSubSys(cellfun(@(x)~isLinked(get_param(x,'object')),allSubSys));
            end

            this.allSubSys=mdlAdvObj.filterResultWithExclusion(allSubSys);
        end

        function doLoops(this)
            this.mInLoop=zeros(1,numel(this.mHandles));

            for j=1:length(this.allSubSys)
                [adjList,adjHandl]=Advisor.Utils.Graph.getBlocksOnlyGraphFromSubsystem(this.allSubSys{j});
                [n,cyc]=Advisor.Utils.Graph.findCycles(adjList);
                if n>0
                    cyc=[cyc{:}];
                    for i=1:length(cyc)
                        this.mInLoop(this.mHandles==adjHandl(cyc(i)))=true;
                    end
                end
            end
        end


        function mRanks=calculateRanks(~,adjList,numNodes,preds,sucss)






            mRanks=ones(1,numNodes);


            g=matlab.internal.graph.MLDigraph(adjList);


            sources=find(arrayfun(@(x)isempty(preds{x}),1:numNodes))';
            sinks=find(arrayfun(@(x)isempty(sucss{x}),1:numNodes))';


            sinks=setdiff(sinks,sources);


            [~,~,layers]=g.layeredLayout(sources,sinks,'auto');


            for i=1:length(layers)
                nodesInLayer=layers{i};
                rank=i;
                for j=1:numel(nodesInLayer)


                    if nodesInLayer(j)<=numNodes
                        mRanks(nodesInLayer(j))=rank;
                    end
                end
            end

        end

        function bResult=isOrientedRight(this,mNumNodes,handls)

            bResult=true;
            for i=1:mNumNodes
                blockH=handls(i);
                if~strcmp(get_param(blockH,'orientation'),'right')
                    if~this.mInLoop(this.mHandles==blockH)
                        bResult=false;
                        return;
                    end
                end
            end

        end

        function bResult=areBlocksSequentialPlaced(this,adjList,mNumNodes,mGHandles,ranks)

            bResult=true;
            dists=Advisor.Utils.Graph.getDistances(adjList);
            for i=1:mNumNodes
                blockH=mGHandles(i);
                if this.mInLoop(this.mHandles==blockH)
                    continue;
                end

                myRank=ranks(i);
                blocksToCheck=mGHandles(arrayfun(@(x)ranks(x)<myRank&&~isinf(dists(x,i)),1:mNumNodes));
                blocksToCheck=setdiff(blocksToCheck,blockH);

                for j=1:length(blocksToCheck)

                    successor_position=get_param(blocksToCheck(j),'position');
                    current_position=get_param(blockH,'position');

                    if successor_position(3)>current_position(1)
                        bResult=false;
                        return;
                    end
                end
            end
        end

        function bResult=areBlocksParallelPlaced(this,adjList,mNumNodes,mGHandles,ranks)



            bResult=true;
            conngrp=Advisor.Utils.Graph.getConnectedComponents(adjList);
            for i=1:mNumNodes
                blockH=mGHandles(i);

                if this.mInLoop(this.mHandles==blockH)
                    continue;
                end
                myRank=ranks(i);

                if myRank==1||myRank==max(ranks)
                    continue;
                end

                blocksToCheck=mGHandles(arrayfun(@(x)ranks(x)==myRank&&conngrp(x)==conngrp(i),1:mNumNodes));
                blocksToCheck=setdiff(blocksToCheck,blockH);

                for j=1:length(blocksToCheck)

                    successor_position=get_param(blocksToCheck(j),'position');
                    current_position=get_param(blockH,'position');

                    if current_position(2)<successor_position(4)&&current_position(4)>=successor_position(2)
                        bResult=false;
                        return;
                    end
                end
            end
        end

    end
end
