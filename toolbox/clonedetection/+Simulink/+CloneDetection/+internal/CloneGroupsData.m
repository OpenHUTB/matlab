classdef CloneGroupsData<handle





    properties
        data;
        m2mObj;
        cloneDetectionStatus;
        libFilePath;
        cloneGroupSidListMap;
        cloneGroupData;
    end

    methods(Access=public)
        function this=CloneGroupsData(obj)
            this.m2mObj=obj.m2mObj;
            this.cloneDetectionStatus=obj.cloneDetectionStatus;
            this.libFilePath=obj.refactoredClonesLibFileName;
            this.cloneGroupSidListMap=obj.cloneGroupSidListMap;

            this.cloneGroupData=[];
            this.getChildren();
        end


        function children=getChildren(this,~)
            if(this.cloneDetectionStatus)
                if~this.m2mObj.enableClonesAnywhere
                    this.data=populateSubsystemChildren(this,this.cloneGroupSidListMap);
                    this.data=[this.data,populateLibraryPatternChildren(this)];
                else
                    this.data=populateLibraryPatternChildrenForClonesAnywhere(this);
                end
            end
            children=this.data;
        end
    end

    methods(Access=private)

        function[numClones,paramDiff]=getNumOfClones(this,keyList,cloneGroupIndex)
            cloneIndex=this.cloneGroupSidListMap(keyList{cloneGroupIndex}).cloneIndex;
            if contains(keyList{cloneGroupIndex},'Exact')
                idx=this.m2mObj.cloneresult.exact{cloneIndex}.index;
            else
                idx=this.m2mObj.cloneresult.similar{cloneIndex}.index;
            end
            numClones=length(this.m2mObj.cloneresult.Before{idx});
            paramDiff=this.m2mObj.cloneresult.dissimiliartyParamNum(idx);
        end


        function children=populateLibraryPatternChildren(this)
            LPCloneGroup=this.m2mObj.cloneresult.Before;



            children='';
            if iscell(LPCloneGroup)
                return;
            end
            len=length(LPCloneGroup.mdlBlks);

            keyList=unique(LPCloneGroup.libsubsysBlk);
            ind=1;

            this.cloneGroupData.Summary.CloneGroups=length(keyList);
            this.cloneGroupData.Summary.SimilarClones=0;
            this.cloneGroupData.Summary.ExactClones=0;
            this.cloneGroupData.CloneGroups=struct;

            for cloneGroupIndex=1:length(keyList)
                cloneGroupIndexAdjusted=this.m2mObj.cloneresult.newIndx(cloneGroupIndex);
                cloneType=DAStudio.message('sl_pir_cpp:creator:sysclonedetc_PrefixExact');

                this.cloneGroupData.CloneGroups(cloneGroupIndex).Name=keyList{cloneGroupIndexAdjusted};
                this.cloneGroupData.CloneGroups(cloneGroupIndex).Summary=[];
                this.cloneGroupData.CloneGroups(cloneGroupIndex).CloneList=[];

                this.cloneGroupData.CloneGroups(cloneGroupIndex).Summary.ParameterDifferences=struct([]);

                nodeChildrenArray={};
                cloneList={};


                numOfClones=0;
                blocksInGroupClones={};
                numBlocksInAClone=0;
                for j=1:len
                    if strcmp(LPCloneGroup.libsubsysBlk{j},keyList{cloneGroupIndexAdjusted})
                        LPCloneGroupRow=['Clone Region ',int2str(ind)];
                        ind=ind+1;
                        numOfClones=numOfClones+1;
                        numBlocksInAClone=length(LPCloneGroup.mdlBlks{j});
                        blocksInGroupClones{1,end+1}=LPCloneGroup.mdlBlks{j};

                        if(this.m2mObj.cloneresult.Before.similarCloneFlag{j}==1)
                            cloneType=DAStudio.message('sl_pir_cpp:creator:sysclonedetc_PrefixSimilar');
                        end

                        nodeChildrenArray{end+1,1}=LPCloneGroupRow;

                        clonesNextIndex=length(cloneList)+1;
                        cloneList{clonesNextIndex,1}.Name=LPCloneGroupRow;
                        cloneList{clonesNextIndex,1}.PatternBlocks=LPCloneGroup.mdlBlks{j};
                        this.m2mObj.region2BlockList(LPCloneGroupRow)=LPCloneGroup.mdlBlks{j};
                    end
                end




                if strcmp(cloneType,DAStudio.message('sl_pir_cpp:creator:sysclonedetc_PrefixSimilar'))
                    this.cloneGroupData.Summary.SimilarClones=...
                    this.cloneGroupData.Summary.SimilarClones+numOfClones;
                else
                    this.cloneGroupData.Summary.ExactClones=...
                    this.cloneGroupData.Summary.ExactClones+numOfClones;
                end

                this.cloneGroupData.CloneGroups(cloneGroupIndex).Summary.Clones=numOfClones;
                this.cloneGroupData.CloneGroups(cloneGroupIndex).Summary.BlocksPerClone=numBlocksInAClone;
                this.cloneGroupData.CloneGroups(cloneGroupIndex).Summary.CloneType=cloneType;
                this.cloneGroupData.CloneGroups(cloneGroupIndex).Summary.BlockDifference=0;

                this.cloneGroupData.CloneGroups(cloneGroupIndex).CloneList=cloneList;
            end

            this.cloneGroupData.Summary.Clones=...
            this.cloneGroupData.Summary.SimilarClones+this.cloneGroupData.Summary.ExactClones;
        end

        function children=populateLibraryPatternChildrenForClonesAnywhere(this)
            LPCloneGroup=this.m2mObj.cloneresult.Before;
            keyList1=keys(this.cloneGroupSidListMap);




            children='';
            if iscell(LPCloneGroup)
                return;
            end


            keyList=length(LPCloneGroup);

            this.cloneGroupData.Summary.CloneGroups=keyList;
            this.cloneGroupData.Summary.SimilarClones=0;
            this.cloneGroupData.Summary.ExactClones=0;
            this.cloneGroupData.CloneGroups=struct;
            this.cloneGroupData.Summary.Clones=0;
            ind=1;
            differentBlockParameterNames=this.m2mObj.creator.differentBlockParamName;

            for i=1:keyList
                cloneIndex=this.m2mObj.cloneresult.newIndx(i);
                numblk=0;
                for j=1:length(LPCloneGroup(cloneIndex).Region)
                    numblk=numblk+length(LPCloneGroup(cloneIndex).Region(j).Candidates);
                end

                if contains(keyList1{i},'Exact')
                    this.cloneGroupData.CloneGroups(i).Name=['Exact Clone Group ',int2str(i)];
                    this.cloneGroupData.Summary.ExactClones=this.cloneGroupData.Summary.ExactClones+length(LPCloneGroup(cloneIndex).Region);
                else
                    this.cloneGroupData.CloneGroups(i).Name=['Similar Clone Group ',int2str(i)];
                    this.cloneGroupData.Summary.SimilarClones=this.cloneGroupData.Summary.SimilarClones+length(LPCloneGroup(cloneIndex).Region);
                end
                this.cloneGroupData.CloneGroups(i).Summary=[];
                this.cloneGroupData.CloneGroups(i).CloneList=[];

                childrenArray=[];
                nodeChildrenArray={};
                cloneList={};


                numOfClones=0;
                blocksInGroupClones={};
                numBlocksInAClone=0;
                for j=1:length(LPCloneGroup(cloneIndex).Region)
                    LPCloneGroupRow=['Clone Region ',int2str(ind)];
                    ind=ind+1;
                    numOfClones=numOfClones+1;
                    numBlocksInAClone=length(LPCloneGroup(cloneIndex).Region(j).Candidates);
                    blocksInGroupClones{1,end+1}=LPCloneGroup(cloneIndex).Region(j).Candidates;
                    nodeChildrenArray{end+1,1}=LPCloneGroupRow;
                    cloneList{j,1}.Name=LPCloneGroupRow;
                    cloneList{j,1}.PatternBlocks=LPCloneGroup(cloneIndex).Region(j).Candidates;
                    this.m2mObj.region2BlockList(LPCloneGroupRow)=LPCloneGroup(cloneIndex).Region(j).Candidates;
                end


                if contains(keyList1{i},'Exact')
                    cloneType=DAStudio.message('sl_pir_cpp:creator:sysclonedetc_PrefixExact');
                else
                    cloneType=DAStudio.message('sl_pir_cpp:creator:sysclonedetc_PrefixSimilar');
                end

                this.cloneGroupData.CloneGroups(i).Summary.Clones=numOfClones;
                this.cloneGroupData.CloneGroups(i).Summary.BlocksPerClone=numBlocksInAClone;
                this.cloneGroupData.CloneGroups(i).Summary.CloneType=cloneType;
                differentblocks=this.m2mObj.cloneresult.differentblocks{i};
                dissimilarityParamNum=this.m2mObj.cloneresult.dissimiliartyParamNum(i);
                this.cloneGroupData.CloneGroups(i).Summary.BlockDifference=this.m2mObj.cloneresult.dissimiliarty{cloneIndex};


                this.cloneGroupData.CloneGroups(i).Summary.ParameterDifferences=struct;
                this.cloneGroupData.CloneGroups(i).Summary.ParameterDifferences.Count=dissimilarityParamNum;
                this.cloneGroupData.CloneGroups(i).Summary.ParameterDifferences.List={};



                if(length(differentblocks)>=1)&&~isempty(differentblocks{1})
                    for idx=1:length(differentblocks{1})
                        this.cloneGroupData.CloneGroups(i).Summary.ParameterDifferences.List(idx).Block=...
                        differentBlockParameterNames(differentblocks{1}(idx)).Block;
                        this.cloneGroupData.CloneGroups(i).Summary.ParameterDifferences.List(ind).ParameterNames=...
                        differentBlockParameterNames(differentblocks{1}(idx)).ParameterNames;
                    end
                end
                this.cloneGroupData.CloneGroups(i).CloneList=cloneList;
                this.cloneGroupData.Summary.Clones=this.cloneGroupData.Summary.Clones+numOfClones;
            end
        end



        function children=populateSubsystemChildren(this,cloneGroupSidListMap)
            keyList=keys(cloneGroupSidListMap);
            children='';
            if isempty(keyList)
                return;
            end

            this.cloneGroupData.Summary.CloneGroups=length(keyList);
            [maxNumOfClones,~]=getNumOfClones(this,keyList,1);
            this.cloneGroupData.Summary.SimilarClones=0;
            this.cloneGroupData.Summary.ExactClones=0;




            this.cloneGroupData.CloneGroups=struct;
            for cloneGroupIndex=1:length(keyList)

                this.cloneGroupData.CloneGroups(cloneGroupIndex).Name=...
                cloneGroupSidListMap(keyList{cloneGroupIndex}).CloneGroupName;
                this.cloneGroupData.CloneGroups(cloneGroupIndex).Summary=[];
                this.cloneGroupData.CloneGroups(cloneGroupIndex).CloneList=[];

                cloneType=DAStudio.message('sl_pir_cpp:creator:sysclonedetc_PrefixSimilar');

                [numOfClones,~]=getNumOfClones(this,keyList,cloneGroupIndex);
                if numOfClones>maxNumOfClones
                    maxNumOfClones=numOfClones;
                end

                if contains(keyList{cloneGroupIndex},'Similar')
                    this.cloneGroupData.Summary.SimilarClones=...
                    this.cloneGroupData.Summary.SimilarClones+numOfClones;
                else
                    this.cloneGroupData.Summary.ExactClones=...
                    this.cloneGroupData.Summary.ExactClones+numOfClones;
                end

                cloneIndex=cloneGroupSidListMap(keyList{cloneGroupIndex}).cloneIndex;


                if contains(keyList{cloneGroupIndex},'Exact')
                    idx=this.m2mObj.cloneresult.exact{cloneIndex}.index;
                    cloneType=DAStudio.message('sl_pir_cpp:creator:sysclonedetc_PrefixExact');
                else
                    idx=this.m2mObj.cloneresult.similar{cloneIndex}.index;

                end


                nodeChildrenArray=this.m2mObj.cloneresult.Before{idx};
                differentblocks=this.m2mObj.cloneresult.differentblocks{idx};
                dissimilarity=this.m2mObj.cloneresult.dissimiliarty{idx};
                dissimilarityParamNum=this.m2mObj.cloneresult.dissimiliartyParamNum(idx);
                numblk=this.m2mObj.cloneresult.NumberBlks(idx);

                differentBlockParameterNames=this.m2mObj.creator.differentBlockParamName;

                this.cloneGroupData.CloneGroups(cloneGroupIndex).Summary.ParameterDifferences=struct;
                this.cloneGroupData.CloneGroups(cloneGroupIndex).Summary.ParameterDifferences.Count=dissimilarityParamNum;
                this.cloneGroupData.CloneGroups(cloneGroupIndex).Summary.ParameterDifferences.List={};



                if(length(differentblocks)>=1)&&~isempty(differentblocks{1})
                    for ind=1:length(differentblocks{1})
                        this.cloneGroupData.CloneGroups(cloneGroupIndex).Summary.ParameterDifferences.List(ind).Block=...
                        differentBlockParameterNames(differentblocks{1}(ind)).Block;
                        this.cloneGroupData.CloneGroups(cloneGroupIndex).Summary.ParameterDifferences.List(ind).ParameterNames=...
                        differentBlockParameterNames(differentblocks{1}(ind)).ParameterNames;
                    end
                end


                for j=1:length(nodeChildrenArray)


                    fname=nodeChildrenArray{j};
                    if~strcmp(get_param(fname,'Type'),'block_diagram')&&...
                        (strcmp(get_param(fname,'LinkStatus'),'resolved')||...
                        strcmp(get_param(fname,'LinkStatus'),'implicit'))&&...
                        isempty(get_param(fname,'linkdata'))
                        nodeChildrenArray{j}=get_param(fname,'ReferenceBlock');
                    end
                end


                if contains(keyList{cloneGroupIndex},'Exact')
                    this.m2mObj.cloneresult.exact{cloneIndex}.targetLib=this.libFilePath;
                else
                    this.m2mObj.cloneresult.similar{cloneIndex}.targetLib=this.libFilePath;
                end

                if isprop(this.m2mObj,'isReplaceExactCloneWithSubsysRef')
                    if(~isempty(cloneIndex))&&this.m2mObj.isReplaceExactCloneWithSubsysRef
                        idx=this.m2mObj.cloneresult.exact{cloneIndex}.index;
                        name=slEnginePir.CloneRefactor.get_subsysref_name(this.m2mObj,this.m2mObj.cloneresult.Before{idx},idx);
                        this.m2mObj.cloneresult.exact{cloneIndex}.targetLib=name;
                    end
                end

                this.cloneGroupData.CloneGroups(cloneGroupIndex).Summary.Clones=numOfClones;
                this.cloneGroupData.CloneGroups(cloneGroupIndex).Summary.BlocksPerClone=numblk;
                this.cloneGroupData.CloneGroups(cloneGroupIndex).Summary.CloneType=cloneType;
                this.cloneGroupData.CloneGroups(cloneGroupIndex).Summary.BlockDifference=length(dissimilarity);

                this.cloneGroupData.CloneGroups(cloneGroupIndex).CloneList=nodeChildrenArray;

            end

            this.cloneGroupData.Summary.Clones=...
            this.cloneGroupData.Summary.SimilarClones+this.cloneGroupData.Summary.ExactClones;
        end
    end
end

