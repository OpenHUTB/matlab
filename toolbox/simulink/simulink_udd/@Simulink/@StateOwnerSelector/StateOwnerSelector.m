function sObj=StateOwnerSelector(stateAccessorBlk,stateAccessorBlkDlg,selectedStateOwnerBlk)





    sObj=Simulink.StateOwnerSelector;
    sObj.ModelObj=get_param(bdroot(stateAccessorBlk),'Object');
    sObj.StateAccessorBlock=stateAccessorBlk;
    sObj.StateAccessorBlockDlg=stateAccessorBlkDlg;



    modelObj=sObj.ModelObj;

    if(slfeature('CachedOwnerBlockList')==0)
        parentObj=findParentObject(modelObj,get_param(stateAccessorBlk,'Object'));
        stateOwnerBlkObjs=findStateOwnerBlocks(parentObj);
        listOfBlocksInModel=find_system(modelObj.Name,'LookUnderMasks','all',...
        'FollowLinks','on','MatchFilter',@Simulink.match.allVariants);
        if~isempty(stateOwnerBlkObjs)
            objPool=[modelObj;stateOwnerBlkObjs];


            for blkIdx=1:length(stateOwnerBlkObjs)
                blkObj=stateOwnerBlkObjs(blkIdx);
                parentObj=blkObj.getParent;
                while(parentObj~=modelObj)
                    if~ismember(parentObj,objPool)


                        if isSubsysChartObject(parentObj)

                            charts=find(parentObj,'-isa','Stateflow.Chart');%#ok
                            objPool(end+1)=charts(1);
                        else
                            objPool(end+1)=parentObj;%#ok
                        end
                    else
                        break;
                    end
                    parentObj=parentObj.getParent;
                end
            end


            newID=0;
            sObj.TreeModel={getMinimumTree(modelObj)};
            sObj.ModelHasStateOwnerBlock=true;
        else
            sObj.TreeModel={Simulink.StateOwnerSelectorTree(1,slroot)};
            sObj.ModelHasStateOwnerBlock=false;
        end
    else
        stateOwnerBlockTreeInfo=get_param(modelObj.Path,'StateOwnerBlockTreeInfo');
        stateOwnerBlkList=stateOwnerBlockTreeInfo.OwnerBlockFlattenedTree;
        blockLevelList=stateOwnerBlockTreeInfo.OwnerBlockFlattenedTreeLevel;
        nOwnerBlocks=length(stateOwnerBlkList);
        blockStatusList=ones(1,nOwnerBlocks);
        stateflowIdx=[];
        commentBlockIdx=[];
        stateOwnerBlkObjs=[];
        for ii=1:nOwnerBlocks
            stateOwnerBlkObjs=[stateOwnerBlkObjs,get_param(stateOwnerBlkList(ii),'Object')];
            if~strcmp(get_param(stateOwnerBlkList(ii),'Commented'),'off')
                commentBlockIdx=[commentBlockIdx,ii];
            end
            if isSubsysChartObject(stateOwnerBlkObjs(ii))

                stateflowIdx=[stateflowIdx,ii];
                stateOwnerBlkObjs(ii)=find(stateOwnerBlkObjs(ii),'-isa','Stateflow.Chart',...
                'Path',getfullname(stateOwnerBlkObjs(ii).Handle));
            end
        end

        showTree=true;
        accParentObj=findParentObject(modelObj,get_param(stateAccessorBlk,'Object'));

        if isa(accParentObj,'Simulink.SubSystem')
            showTree=false;
            if~isSubsysChartObject(accParentObj)
                for ii=1:nOwnerBlocks
                    if isa(stateOwnerBlkObjs(ii),'Simulink.SubSystem')
                        if isSameObject(accParentObj,stateOwnerBlkObjs(ii),0)
                            blockStatusList=markBlksForAccessorInStateflow(blockLevelList,ii);
                            showTree=true;
                            break;
                        end
                    end
                end
            elseif~isempty(stateflowIdx)
                for ii=1:length(stateflowIdx)
                    if isSameObject(accParentObj,stateOwnerBlkObjs(stateflowIdx(ii)),1)
                        blockStatusList=markBlksForAccessorInStateflow(blockLevelList,stateflowIdx(ii));
                        if(ii<length(stateflowIdx))
                            stateflowIdx=stateflowIdx(ii+1:end);
                        else
                            stateflowIdx=[];
                        end
                        showTree=true;
                        break;
                    end
                end
            end
        end

        if showTree
            if slfeature('StateflowStateReset')
                stateflowIdx=getNonStateOwnerStateflowBlocks(stateOwnerBlkObjs,stateflowIdx);
            end
            if~isempty(stateflowIdx)
                blockStatusList=markBlockStatusInTree(stateOwnerBlkObjs,blockLevelList,stateflowIdx,blockStatusList);
            end
            if~isempty(commentBlockIdx)
                blockStatusList=markBlockStatusInTree(stateOwnerBlkObjs,blockLevelList,commentBlockIdx,blockStatusList);
            end
            [stateOwnerBlkObjs,blockLevelList]=updateBlockList(stateOwnerBlkObjs,blockLevelList,blockStatusList);
        end
        stateOwnerBlkObjs=[modelObj,stateOwnerBlkObjs];
        blockLevelList=[0,blockLevelList];
        if showTree
            sObj.TreeModel={getMinimumTree2(stateOwnerBlkObjs,blockLevelList)};
            sObj.ModelHasStateOwnerBlock=true;
        else
            sObj.TreeModel={Simulink.StateOwnerSelectorTree(1,slroot)};
            sObj.ModelHasStateOwnerBlock=false;
        end
    end

    accessedStateName='';

    if~isempty(selectedStateOwnerBlk)&&isBlockInGraph(selectedStateOwnerBlk,modelObj)...
        &&sObj.isValidStateOwnerBlock(get_param(selectedStateOwnerBlk,'Object'))



        if(slfeature('AccessingMultipleStatesBlocks')>=1)
            accessedStateName=get_param(stateAccessorBlk,'AccessedStateName');
            stateNameList=get_param(selectedStateOwnerBlk,'StateNameList');
            if isempty(accessedStateName)
                accessedStateName='<default>';
            end
            if(length(stateNameList)>1)
                selectedStateOwnerBlkAndState=[selectedStateOwnerBlk,'/',accessedStateName];
            else
                selectedStateOwnerBlkAndState=selectedStateOwnerBlk;
            end
            sObj.TreeExpandItems=...
            getExpandTreeItems(selectedStateOwnerBlk,modelObj.Name);
            sObj.TreeSelectedItem=selectedStateOwnerBlkAndState;
            sObj.SelectedStateOwner=selectedStateOwnerBlk;
        else
            sObj.TreeExpandItems=...
            getExpandTreeItems(selectedStateOwnerBlk,modelObj.Name);
            sObj.TreeSelectedItem=selectedStateOwnerBlk;
            sObj.SelectedStateOwner=selectedStateOwnerBlk;
        end
    else
        sObj.TreeExpandItems={};
        sObj.TreeSelectedItem='';
        sObj.SelectedStateOwner='';
    end

    sObj.SelectedOwnerState=accessedStateName;
    sObj.HighlightedBlock='';

    function treeNode=getMinimumTree(obj)
        newID=newID+1;
        treeNode=Simulink.StateOwnerSelectorTree(newID,obj);
        childrenNames={};
        childrenNodes={};
        children=obj.getChildren;
        chIdx=1;
        while(chIdx<=length(children))
            childObj=children(chIdx);
            if~ismember(childObj,objPool)
                chIdx=chIdx+1;
                continue;
            end
            if~isempty(find(strcmp(childObj.getFullName,listOfBlocksInModel),1))
                [childrenNodes,childrenNames]=populateTreeWithStateInfo(childObj,childrenNodes,childrenNames);
            else
                grandChildren=childObj.getChildren;
                for cg=1:length(grandChildren)
                    children(end+1)=grandChildren(cg);
                end
            end
            chIdx=chIdx+1;
        end
        [~,sortIndices]=sort(childrenNames);
        treeNode.Children=childrenNodes(sortIndices);
    end

    function stateflowIdx2=getNonStateOwnerStateflowBlocks(stateOwnerBlkObjs,stateflowIdx)
        stateflowIdx2=[];
        for idx=stateflowIdx
            if~sObj.isValidStateOwnerBlock(stateOwnerBlkObjs(idx))
                stateflowIdx2=[stateflowIdx2,idx];
            end
        end
    end

    function[childrenNodes,childrenNames]=populateTreeWithStateInfo(obj,childrenNodes,childrenNames)
        if(slfeature('AccessingMultipleStatesBlocks')<1)
            childrenNames{end+1}=obj.Name;
            childrenNodes{end+1}=getMinimumTree(obj);
        elseif(isa(obj,'Simulink.SubSystem')||isa(obj,'Stateflow.Chart'))
            childrenNames{end+1}=obj.Name;
            childrenNodes{end+1}=getMinimumTree(obj);
        else
            isChildrenNameExist=false;
            isDoubleIntStateNameEmpty=false;
            if~isa(obj,'struct')&&~isa(obj,'Simulink.BlockDiagram')&&ismember(obj,objPool)
                stateNameList=get_param(obj.getFullName,'StateNameList');
                nStates=length(stateNameList);
                if(nStates==1)
                    stateNameList{1}=obj.Name;
                else
                    for i=1:nStates
                        if(isempty(stateNameList{i}))
                            stateNameList=cell(1);
                            stateNameList{1}='Make sure the state name is valid before selecting';
                            isDoubleIntStateNameEmpty=true;
                            break;
                        end
                    end
                end
                isChildrenNameExist=true;
            elseif isa(obj,'Simulink.Outport')
                stateNameList{1}='<default>';
                isChildrenNameExist=true;
            end

            if isChildrenNameExist
                chIdx=1;
                if(length(stateNameList)>1||isDoubleIntStateNameEmpty)
                    newID=newID+1;
                    childrenNames{end+1}=obj.Name;
                    childrenNodes{end+1}=Simulink.StateOwnerSelectorTree(newID,obj);
                    childrenNodes{end}.Children={};
                    tempNodes={};
                    tempNames={};
                    while(chIdx<=length(stateNameList))
                        childObjSub.Name=stateNameList{chIdx};
                        childObjSub.getChildren={};
                        childObjSub.IsStatesNameEmpty=isDoubleIntStateNameEmpty;
                        tempNames{end+1}=childObjSub.Name;%#ok
                        newID=newID+1;
                        tempNodes{end+1}=Simulink.StateOwnerSelectorTree(newID,childObjSub);%#ok

                        chIdx=chIdx+1;
                    end
                    [~,sortIndices]=sort(tempNames);
                    childrenNodes{end}.Children=tempNodes(sortIndices);
                else
                    childObjSub.Name=stateNameList{1};
                    childObjSub.getChildren={};
                    childObjSub.IsStatesNameEmpty=isDoubleIntStateNameEmpty;
                    newID=newID+1;
                    childrenNames{end+1}=childObjSub.Name;
                    childrenNodes{end+1}=Simulink.StateOwnerSelectorTree(newID,childObjSub);
                    childrenNodes{end}.Children={};
                end
            end
        end
    end


    function treeNode=getMinimumTree2(blockObjList,blockLevelList)


        L=length(blockLevelList);
        for i=1:L
            blockNodes(i)=Simulink.StateOwnerSelectorTree(i,blockObjList(i));
        end
        newID=L+1;
        for i=1:L
            obj=blockObjList(i);
            if(isa(obj,'Simulink.SubSystem')||isa(obj,'Simulink.BlockDiagram')||isa(obj,'Stateflow.Chart'))
                childrenNode=findChildrenForSubsys(i,blockNodes,blockObjList,blockLevelList);
                blockNodes(i).Children=childrenNode;
            else
                stateNameList=get_param(obj.getFullName,'StateNameList');
                nStates=length(stateNameList);
                if(nStates>1)
                    isMultiStateNamesEmpty=false;
                    childrenNode={};
                    for j=1:nStates
                        if(isempty(stateNameList{j}))
                            stateNameList=cell(1);
                            stateNameList{1}='Make sure the state name is valid before selecting';
                            isMultiStateNamesEmpty=true;
                            nStates=1;
                            break;
                        end
                    end
                    stateNameList=sort(stateNameList);
                    for j=1:nStates
                        nameObj.Name=stateNameList{j};
                        nameObj.getChildren={};
                        nameObj.IsStatesNameEmpty=isMultiStateNamesEmpty;
                        childrenNode{end+1}=Simulink.StateOwnerSelectorTree(newID,nameObj);
                        newID=newID+1;
                    end
                    blockNodes(i).Children=childrenNode;
                end
            end
        end
        treeNode=blockNodes(1);
    end

    function childrenNodes=findChildrenForSubsys(subsysIndex,blockNodeList,blockObjList,blockLevelList)
        childrenNodes={};
        childrenNames={};
        level=blockLevelList(subsysIndex);
        index=subsysIndex+1;
        while(index<=length(blockLevelList)&&blockLevelList(index)>level)
            if(blockLevelList(index)==level+1)
                childrenNodes{end+1}=blockNodeList(index);
                childrenNames{end+1}=blockObjList(index).Name;
            end
            index=index+1;
        end
    end

    function[blockObjListN,blockLevelListN]=updateBlockList(blockObjList,blockLevelList,blockStatusList)
        j=1;
        blockObjListN=[];
        blockLevelListN=[];
        for i=1:length(blockStatusList)
            if(blockStatusList(i)~=0)
                blockObjListN=[blockObjListN,blockObjList(i)];
                blockLevelListN=[blockLevelListN,blockLevelList(i)];
                j=j+1;
            end
        end
    end
    function statusNew=markBlksForAccessorInStateflow(blkLevelList,index)
        L=length(blkLevelList);
        statusNew=zeros(1,L);

        j0=index;j=j0+1;statusNew(j0)=1;


        while(j<=L&&blkLevelList(j)>blkLevelList(j0))
            statusNew(j)=1;
            j=j+1;
        end


        k=j0-1;

        sLevel=blkLevelList(j0)-1;
        while(k>0)
            if blkLevelList(k)>=blkLevelList(j0)
                k=k-1;
                continue;
            end
            if(blkLevelList(k)==sLevel)
                statusNew(k)=1;
                sLevel=sLevel-1;
            end
            k=k-1;
        end
    end

    function statusNew=markBlockStatusInTree(blkObjs,blkLevelList,startIndexes,status)
        L=length(blkLevelList);
        statusNew=status;
        for i=1:length(startIndexes)
            if statusNew(startIndexes(i))
                j0=startIndexes(i);j=j0+1;
                if~sObj.isValidStateOwnerBlock(blkObjs(j0))
                    statusNew(j0)=0;
                end


                while(j<=L&&blkLevelList(j)>blkLevelList(j0))
                    statusNew(j)=0;
                    j=j+1;
                end
                k=j0-1;


                while(k>0&&~sObj.isValidStateOwnerBlock(blkObjs(k))&&...
                    (j>L||blkLevelList(k)>=blkLevelList(j)))
                    statusNew(k)=0;
                    k=k-1;
                end
            end
        end
    end

    function ret=isSameObject(accParentObj,subSysObj,isAccParentObjStateflow)
        ret=false;
        accParentObjPath=[accParentObj.Path,'/',accParentObj.Name];
        if isAccParentObjStateflow
            subsysObjPath=subSysObj.Path;
        else
            subsysObjPath=[subSysObj.Path,'/',subSysObj.Name];
        end
        cmpLength=max(length(accParentObjPath),length(subsysObjPath));
        if strncmp(accParentObjPath,subsysObjPath,cmpLength)
            ret=true;
        end
    end

    function expandItems=getExpandTreeItems(currentItem,modelName)
        expandItems={currentItem};
        done=false;
        while~done
            currentItem=get_param(currentItem,'Parent');
            expandItems=[currentItem,expandItems];%#ok
            done=strcmp(currentItem,modelName);
        end
    end

    function parentObj=findNonVirtualParentSS(modelObj,blkObj)
        parentObj=blkObj.getParent;
        while parentObj~=modelObj&&...
            parentObj.isa('Simulink.SubSystem')&&...
            strcmp(get_param(parentObj.Handle,'Virtual'),'on')
            parentObj=parentObj.getParent;
        end
    end







    function parentObj=findParentObject(modelObj,blkObj)
        parentObj=blkObj.getParent;
        while parentObj~=modelObj
            if(parentObj.isa('Stateflow.Chart')||isSubsysChartObject(parentObj))

                if parentObj.isa('Stateflow.Chart')
                    parentObj=get_param(parentObj.Path,'Object');
                end
                break;
            else
                if(parentObj.isa('Simulink.SubSystem')&&...
                    (strcmp(get_param(parentObj.Handle,'Virtual'),'on')||...
                    ~strcmp(get_param(parentObj.Handle,'SystemType'),'EventFunction')))

                    parentObj=parentObj.getParent;
                else



                    parentObj=findNonVirtualParentSS(modelObj,parentObj);

                    break;
                end

            end
        end
    end

    function result=isSubsysChartObject(blkObj)
        result=false;
        if isa(blkObj,'Simulink.SubSystem')
            subsystem_path=[blkObj.Parent,'/',blkObj.Name];
            stateflow=find(blkObj,'-isa','Stateflow.Chart');
            for i=1:numel(stateflow)
                curChart=stateflow(i);
                if strcmp(curChart.Path,subsystem_path)
                    result=true;
                end
            end
        end
    end


    function stateOwnerBlkObjs=findStateOwnerBlocks(parentObj)

        if parentObj.isa('Stateflow.Chart')
            parentObj=get_param(parentObj.Path,'Object');
        end

        stateOwnerBlkObjs=find(parentObj,'IsStateOwnerBlock','on');


        stateflowCharts=find(parentObj,'-isa','Stateflow.Chart');


        subsystem_path=[parentObj.Parent,'/',parentObj.Name];
        for i=1:numel(stateflowCharts)
            curChart=stateflowCharts(i);
            if strcmp(curChart.Path,subsystem_path)
                stateflowCharts(i)=[];
                break;
            end
        end

        for j=1:numel(stateflowCharts)
            chart=stateflowCharts(j);
            blkIndx=1;
            while blkIndx<=numel(stateOwnerBlkObjs)
                ownerBlk=stateOwnerBlkObjs(blkIndx);
                if isParent(chart,ownerBlk)
                    stateOwnerBlkObjs(blkIndx)=[];
                else
                    blkIndx=blkIndx+1;
                end
            end
        end
    end

    function ret=isParent(parentObj,childObj)
        ret=false;
        if parentObj.isa('Stateflow.Chart')
            parentObj=get_param(parentObj.Path,'Object');
        end
        subsystem_path=[parentObj.Parent,'/',parentObj.Name];
        if strncmp(childObj.Parent,subsystem_path,length(subsystem_path))
            ret=true;
        end
    end

    function isInGraph=isBlockInGraph(blockPath,modelObj)
        isInGraph=true;
        try
            blockObj=get_param(blockPath,'Object');
        catch ME
            isInGraph=false;
            return;
        end
        isInGraph=strcmp(get_param(blockPath,'Commented'),'off');



        while isInGraph&&~strcmp(blockObj.Path,modelObj.Path)
            isInGraph=strcmp(get_param(blockObj.Path,'Commented'),'off');
            blockObj=blockObj.getParent;
        end
    end
end
