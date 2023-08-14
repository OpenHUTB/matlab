classdef BlockStateStatsClass<handle


    properties(SetAccess=private)
BlockStats
StateStats
BlockMap
StateMap
    end

    methods

        function obj=BlockStateStatsClass(pd)
            import solverprofiler.util.*

            obj.BlockMap=containers.Map();
            obj.StateMap=containers.Map();
            obj.StateStats=obj.makeStateStatsStruct();
            obj.BlockStats=obj.makeBlockStatsStruct();

            if isempty(pd),return;end


            allBlockPath=cell(length(pd.odeInfo.stateInfo.source),1);
            for i=1:length(pd.odeInfo.stateInfo.source)
                paths=pd.odeInfo.stateInfo.source(i).blockPath;
                allBlockPath{i}=utilFormatBlockPathIfWithinModelRef(paths);
            end


            for i=1:length(pd.odeInfo.stateInfo.source)

                blockName=allBlockPath{i};

                if~isKey(obj.BlockMap,blockName)


                    blockStatsIndex=obj.getNumberOfEntries(obj.BlockStats)+1;
                    obj.BlockStats(blockStatsIndex)=obj.makeBlockStatsStruct();


                    obj.BlockMap(blockName)=blockStatsIndex;


                    offset=length([obj.BlockStats.stateIdx]);
                    obj.BlockStats(blockStatsIndex).blockName=blockName;
                    obj.BlockStats(blockStatsIndex).stateIdx=...
                    (offset+1:offset+pd.odeInfo.stateInfo.source(i).width);


                    blockNameAfterUnwrap=solverprofiler.util.utilUnwrapBlockNameIfInModelRef(blockName);
                    if obj.isSSCExplorerEnabled(blockNameAfterUnwrap)
                        obj.BlockStats(blockStatsIndex).blockNameForSimscape=blockNameAfterUnwrap;
                    end


                else
                    blockStatsIndex=obj.BlockMap(blockName);
                    offset=length([obj.BlockStats.stateIdx]);
                    obj.BlockStats(blockStatsIndex).stateIdx=...
                    [obj.BlockStats(blockStatsIndex).stateIdx,...
                    (offset+1:offset+pd.odeInfo.stateInfo.source(i).width)];
                end


                offset=obj.getNumberOfEntries(obj.StateStats);

                for j=1:pd.odeInfo.stateInfo.source(i).width

                    obj.StateStats(j+offset)=obj.makeStateStatsStruct();


                    obj.StateStats(j+offset).blockIdx=blockStatsIndex;


                    stateName=pd.odeInfo.stateInfo.source(i).name;
                    if isempty(stateName)
                        stateName=blockName;
                    elseif~contains(stateName,'/')&&~contains(stateName,'.')



                        stateName=[blockName,'/',stateName];
                    end
                    stateName=strrep(stateName,newline,' ');
                    if pd.odeInfo.stateInfo.source(i).width>1
                        stateName=[stateName,'(',num2str(j),')'];
                    end
                    obj.StateStats(j+offset).stateName=stateName;
                end

            end


            stateNames={obj.StateStats.stateName};
            [~,inds,~]=unique(stateNames);
            obj.StateStats=obj.StateStats(inds);


            key={obj.StateStats.stateName};
            value=num2cell(1:length(obj.StateStats));
            obj.StateMap=containers.Map(key,value);
        end


        function val=blockExist(obj,blockName)
            val=isKey(obj.BlockMap,blockName);
        end


        function val=stateExist(obj,stateName)
            val=isKey(obj.StateMap,stateName);
        end


        function addBlockStats(obj,blkName)
            import solverprofiler.util.*
            index=size(obj.BlockMap,1)+1;
            obj.BlockMap(blkName)=index;
            obj.BlockStats(index)=obj.makeBlockStatsStruct();
            obj.BlockStats(index).blockName=blkName;

            blockNameAfterUnwrap=utilUnwrapBlockNameIfInModelRef(blkName);

            if obj.isSSCExplorerEnabled(blockNameAfterUnwrap)
                obj.BlockStats(index).blockNameForSimscape=blockNameAfterUnwrap;
            end
        end


        function index=getBlockStatsIndex(obj,blockName)
            index=obj.BlockMap(blockName);
        end


        function index=getStateStatsIndex(obj,stateName)
            index=obj.StateMap(stateName);
        end


        function name=getBlockName(obj,index)
            name=obj.BlockStats(index).blockName;
        end


        function name=getStateName(obj,index)
            name=obj.StateStats(index).stateName;
        end


        function nameList=getStateNameList(obj,stateIdxLst)
            nameList={obj.StateStats(stateIdxLst).stateName};
        end


        function name=getSSCName(obj,blockName)
            if isempty(blockName)||~isKey(obj.BlockMap,blockName)
                name='';
            else
                blockIndex=obj.BlockMap(blockName);
                name=obj.BlockStats(blockIndex).blockNameForSimscape;
            end
        end


        function blockIndex=getBlockIdxFromStateIdx(obj,stateIdx)
            blockIndex=obj.StateStats(stateIdx).blockIdx;
        end


        function name=getBlockNameFromStateIdx(obj,stateIdx)
            if isempty(stateIdx)
                name='';
            else
                blockIdx=obj.StateStats(stateIdx).blockIdx;
                name=obj.BlockStats(blockIdx).blockName;
            end
        end


        function stateIdx=getStateIdxFromBlockIdx(obj,blockIdx)
            stateIdx=obj.BlockStats(blockIdx).stateIdx;
        end


        function numBlocks=getNumberOfBlocks(obj)
            numBlocks=size(obj.BlockMap,1);
        end


        function numBlocks=getNumBlocksWithState(obj)
            numBlocks=length(unique([obj.StateStats.blockIdx]));
        end


        function numStates=getNumberOfStates(obj)
            numStates=size(obj.StateMap,1);
        end
    end


    methods(Static)

        function numberOfEntries=getNumberOfEntries(entries)

            numberOfEntries=length(entries);



            if length(entries)==1
                names=fieldnames(entries);
                if isempty(entries.(names{1}))
                    numberOfEntries=0;
                end
            end
        end

        function stateStatsStruct=makeStateStatsStruct()


            stateStatsStruct=struct(...
            'stateName','',...
            'blockIdx',[]);
        end

        function blockStatsStruct=makeBlockStatsStruct()


            blockStatsStruct=struct(...
            'blockName','',...
            'blockNameForSimscape','',...
            'stateIdx',[]);
        end

        function val=isSSCExplorerEnabled(blockName)
            try
                type=get_param(blockName,'blocktype');
                if contains(type,'Simscape')
                    val=true;
                else
                    val=false;
                end
            catch
                val=false;
            end
        end

    end

end