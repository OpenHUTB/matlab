classdef CloneGroups<handle




    properties
        data;
        columns;
        m2mObj;
        cloneDetectionStatus;
        libFilePath;
        ddgRightObj;
        cloneGroupSidListMap;
    end

    methods(Access=public)
        function this=CloneGroups(ddgRightObj,libFilePath,m2mObj,...
            cloneDetectionStatus,cloneGroupSidListMap)
            this.m2mObj=m2mObj;
            this.data=[];


            this.columns={DAStudio.message('sl_pir_cpp:creator:cloneGroupsSSColumn1'),...
            DAStudio.message('sl_pir_cpp:creator:cloneGroupsSSColumn2'),...
            DAStudio.message('sl_pir_cpp:creator:cloneGroupsSSColumn3'),...
            DAStudio.message('sl_pir_cpp:creator:cloneGroupsSSColumn4'),...
            DAStudio.message('sl_pir_cpp:creator:cloneGroupsSSColumn5'),...
            DAStudio.message('sl_pir_cpp:creator:cloneGroupsSSColumn6'),...
            DAStudio.message('sl_pir_cpp:creator:cloneGroupsSSColumn8'),...
            DAStudio.message('sl_pir_cpp:creator:cloneGroupsSSColumn9')};
            this.cloneDetectionStatus=cloneDetectionStatus;
            this.libFilePath=libFilePath;
            this.ddgRightObj=ddgRightObj;
            this.cloneGroupSidListMap=cloneGroupSidListMap;
        end


        function children=getChildren(this,~)
            if~isempty(this.data)
                children=this.data;
                return;
            else
                if(this.cloneDetectionStatus)
                    if this.m2mObj.enableClonesAnywhere
                        this.data=populateClonesEverywhereResults(this);
                    else
                        this.data=populateSubsystemChildren(this,this.cloneGroupSidListMap);
                        this.data=[this.data,populateLibraryPatternChildren(this)];
                    end
                end
                children=this.data;
            end
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


        function children=populateClonesEverywhereResults(this)

            if~strcmp(this.m2mObj.mdlName,get_param(this.ddgRightObj.cloneUIObj.model,'name'))
                children='';
                return;
            end
            keyList=keys(this.cloneGroupSidListMap);
            if isempty(keyList)
                children='';
                return;
            end
            results=this.m2mObj.cloneresult;
            maxPlotLength=numel(results.Before);
            similarCount=0;



            for cloneGroupIndex=1:length(keyList)
                numOfClones=numel(results.Before(cloneGroupIndex).Region);
                if numOfClones>maxPlotLength
                    maxPlotLength=numOfClones;
                end
                if contains(keyList{cloneGroupIndex},'Similar')
                    similarCount=similarCount+1;
                end
            end


            exactColor=CloneDetectionUI.internal.util.getExactColorCodeNumerical;
            darkest=CloneDetectionUI.internal.util.getSimilarColorCodeNumerical;
            lightest=CloneDetectionUI.internal.util.getSimilarLightColorCodeNumerical;
            red=linspace(lightest(1),darkest(1),similarCount+1);
            green=linspace(lightest(2),darkest(2),similarCount+1);
            blue=linspace(lightest(3),darkest(3),similarCount+1);


            ind=1;
            children=repmat(CloneDetectionUI.internal.SpreadSheetItem.CloneGroups(),[1,length(keyList)]);
            for cloneGroupIndex=1:length(keyList)
                cloneIndex=this.cloneGroupSidListMap(keyList{cloneGroupIndex}).cloneIndex;


                if contains(keyList{cloneGroupIndex},'Exact')
                    idx=this.m2mObj.cloneresult.exact{cloneIndex}.index;
                else
                    idx=this.m2mObj.cloneresult.similar{cloneIndex}.index;
                end


                nodeChildrenArray=this.m2mObj.cloneresult.Before(idx).Region;
                differentblocks=this.m2mObj.cloneresult.differentblocks{idx};
                dissimilarity=this.m2mObj.cloneresult.dissimiliarty{idx};
                dissimilarityParamNum=this.m2mObj.cloneresult.dissimiliartyParamNum(idx);
                numblk=results.NumberBlks(idx);


                childrenArray=repmat(CloneDetectionUI.internal.SpreadSheetItem.CloneGroups(),[1,numel(results.Before(idx).Region)]);
                for j=1:length(nodeChildrenArray)



                    fname=['Clone Region ',int2str(ind)];
                    ind=ind+1;

                    checkBoxCheck='1';
                    if~isempty(this.m2mObj.excluded_sysclone)
                        if isKey(this.m2mObj.excluded_sysclone,nodeChildrenArray(j).Candidates)
                            checkBoxCheck='0';
                        end
                    end


                    childrenArray(j)=...
                    CloneDetectionUI.internal.SpreadSheetItem.CloneGroups...
                    (this.ddgRightObj,this.m2mObj,checkBoxCheck,fname,...
                    [],'',int2str(numblk),'',int2str(dissimilarityParamNum),...
                    j,differentblocks{j});

                end


                cloneGroupName=this.cloneGroupSidListMap(keyList{cloneGroupIndex}).CloneGroupName;
                colorCell={};
                numClones=numel(results.Before(idx).Region);

                if contains(keyList{cloneGroupIndex},'Exact')
                    this.m2mObj.cloneresult.exact{cloneIndex}.targetLib=this.libFilePath;
                    colorCell={exactColor(1),exactColor(2),exactColor(3)};
                else
                    this.m2mObj.cloneresult.similar{cloneIndex}.targetLib=this.libFilePath;
                    colorCell={red(similarCount),green(similarCount),blue(similarCount)};
                    similarCount=similarCount-1;
                end



                childObj=CloneDetectionUI.internal.SpreadSheetItem.CloneGroups...
                (this.ddgRightObj,this.m2mObj,'0',cloneGroupName,childrenArray,...
                int2str(length(nodeChildrenArray)),int2str(numblk),...
                int2str(length(dissimilarity)),...
                int2str(dissimilarityParamNum),idx,'');

                childObj.setCloneComparisonProperties(cloneGroupName,numClones,...
                maxPlotLength,colorCell,['Parameter difference:',int2str(dissimilarityParamNum)]);

                children(cloneGroupIndex)=childObj;
                for k=1:length(childrenArray)
                    childrenArray(k).parent=children(cloneGroupIndex);
                end
            end



        end

        function children=populateLibraryPatternChildren(this)

            if~strcmp(this.m2mObj.mdlName,get_param(this.ddgRightObj.cloneUIObj.model,'name'))
                children='';
                return;
            end
            LPCloneGroup=this.m2mObj.cloneresult.Before;



            if iscell(LPCloneGroup)
                children='';
                return;
            end
            len=length(LPCloneGroup.mdlBlks);

            keyList=unique(LPCloneGroup.libsubsysBlk);
            children=repmat(CloneDetectionUI.internal.SpreadSheetItem.CloneGroups(),[1,length(keyList)]);
            ind=1;
            for cloneGroupIndex=1:length(keyList)
                cloneIndex=this.m2mObj.cloneresult.newIndx(cloneGroupIndex);

                numblk=this.m2mObj.cloneresult.NumberBlks(cloneIndex);

                childrenArray=[];


                childrenNum=0;
                for j=1:len
                    if strcmp(LPCloneGroup.libsubsysBlk{j},keyList{cloneIndex})
                        LPCloneGroupRow=['Clone Region ',int2str(ind)];
                        ind=ind+1;
                        childrenNum=childrenNum+1;
                        checkBoxCheck='1';
                        if this.m2mObj.is_excluded_sysclone(LPCloneGroup.mdlBlks{j})
                            checkBoxCheck='0';
                        end


                        curChild=CloneDetectionUI.internal.SpreadSheetItem.CloneGroups...
                        (this.ddgRightObj,this.m2mObj,checkBoxCheck,LPCloneGroupRow,[],...
                        '',int2str(numblk),'','',...
                        j,'');
                        childrenArray=[childrenArray,curChild];
                    end
                end

                cloneGroupName=keyList{cloneIndex};
                childObj=CloneDetectionUI.internal.SpreadSheetItem.CloneGroups...
                (this.ddgRightObj,this.m2mObj,'1',cloneGroupName,childrenArray,...
                childrenNum,int2str(numblk),...
                '','',cloneIndex,'');

                children(cloneGroupIndex)=childObj;
                for k=1:length(childrenArray)
                    childrenArray(k).parent=children(cloneGroupIndex);
                end
            end
        end

        function children=populateSubsystemChildren(this,cloneGroupSidListMap)

            if~strcmp(this.m2mObj.mdlName,get_param(this.ddgRightObj.cloneUIObj.model,'name'))
                children='';
                return;
            end
            keyList=keys(cloneGroupSidListMap);
            if isempty(keyList)
                children='';
                return;
            end

            [maxPlotLength,~]=getNumOfClones(this,keyList,1);
            similarCount=0;



            for cloneGroupIndex=1:length(keyList)
                [numOfClones,~]=getNumOfClones(this,keyList,cloneGroupIndex);
                if numOfClones>maxPlotLength
                    maxPlotLength=numOfClones;
                end
                if contains(keyList{cloneGroupIndex},'Similar')
                    similarCount=similarCount+1;
                end
            end


            exactColor=CloneDetectionUI.internal.util.getExactColorCodeNumerical;
            darkest=CloneDetectionUI.internal.util.getSimilarColorCodeNumerical;
            lightest=CloneDetectionUI.internal.util.getSimilarLightColorCodeNumerical;
            red=linspace(lightest(1),darkest(1),similarCount+1);
            green=linspace(lightest(2),darkest(2),similarCount+1);
            blue=linspace(lightest(3),darkest(3),similarCount+1);



            children=repmat(CloneDetectionUI.internal.SpreadSheetItem.CloneGroups(),[1,length(keyList)]);
            for cloneGroupIndex=1:length(keyList)
                cloneIndex=cloneGroupSidListMap(keyList{cloneGroupIndex}).cloneIndex;


                if contains(keyList{cloneGroupIndex},'Exact')
                    idx=this.m2mObj.cloneresult.exact{cloneIndex}.index;
                else
                    idx=this.m2mObj.cloneresult.similar{cloneIndex}.index;
                end


                nodeChildrenArray=this.m2mObj.cloneresult.Before{idx};
                differentblocks=this.m2mObj.cloneresult.differentblocks{idx};
                dissimilarity=this.m2mObj.cloneresult.dissimiliarty{idx};
                dissimilarityParamNum=this.m2mObj.cloneresult.dissimiliartyParamNum(idx);
                numblk=this.m2mObj.cloneresult.NumberBlks(idx);


                childrenArray=repmat(CloneDetectionUI.internal.SpreadSheetItem.CloneGroups(),[1,length(nodeChildrenArray)]);
                for j=1:length(nodeChildrenArray)



                    fname=nodeChildrenArray{j};
                    if~strcmp(get_param(fname,'Type'),'block_diagram')&&...
                        (strcmp(get_param(fname,'LinkStatus'),'resolved')||strcmp(get_param(fname,'LinkStatus'),'implicit'))&&...
                        isempty(get_param(fname,'linkdata'))
                        nodeChildrenArray{j}=get_param(fname,'ReferenceBlock');
                    end

                    checkBoxCheck='1';
                    if~isempty(this.m2mObj.excluded_sysclone)
                        if isKey(this.m2mObj.excluded_sysclone,nodeChildrenArray{j})
                            checkBoxCheck='0';
                        end
                    end


                    childrenArray(j)=...
                    CloneDetectionUI.internal.SpreadSheetItem.CloneGroups...
                    (this.ddgRightObj,this.m2mObj,checkBoxCheck,nodeChildrenArray{j},...
                    [],'',int2str(numblk),'',int2str(dissimilarityParamNum),...
                    '',differentblocks{j});

                end


                cloneGroupName=cloneGroupSidListMap(keyList{cloneGroupIndex}).CloneGroupName;
                colorCell={};
                [numClones,paramDiff]=getNumOfClones(this,keyList,cloneGroupIndex);

                if contains(keyList{cloneGroupIndex},'Exact')
                    this.m2mObj.cloneresult.exact{cloneIndex}.targetLib=this.libFilePath;
                    colorCell={exactColor(1),exactColor(2),exactColor(3)};
                else
                    this.m2mObj.cloneresult.similar{cloneIndex}.targetLib=this.libFilePath;
                    colorCell={red(similarCount),green(similarCount),blue(similarCount)};
                    similarCount=similarCount-1;
                end



                childObj=CloneDetectionUI.internal.SpreadSheetItem.CloneGroups...
                (this.ddgRightObj,this.m2mObj,'1',cloneGroupName,childrenArray,...
                int2str(length(nodeChildrenArray)),int2str(numblk),...
                int2str(length(dissimilarity)),...
                int2str(dissimilarityParamNum),cloneIndex,'');

                childObj.setCloneComparisonProperties(cloneGroupName,numClones,...
                maxPlotLength,colorCell,['Parameter difference:',int2str(paramDiff)]);

                children(cloneGroupIndex)=childObj;
                for k=1:length(childrenArray)
                    childrenArray(k).parent=children(cloneGroupIndex);
                end
            end
        end
    end
end




