function sharedLists=gatherSharedDT(h,blkObj)




    sharedLists={};


    hBusAssignBlk=blkObj.Handle;
    assignedSignalStr=get_param(hBusAssignBlk,'AssignedSignals');
    listOfAssign=regexp(assignedSignalStr,',','split');
    busAssignBlkPortHandles=get_param(hBusAssignBlk,'PortHandles');

    if hIsVirtualBus(h,busAssignBlkPortHandles.Inport(1))
        targetBusPortObject=get_param(busAssignBlkPortHandles.Inport(1),'Object');
        virBusSource=targetBusPortObject.getActualSrcForVirtualBus;

        for assignListIdx=1:length(listOfAssign)


            assignmentInportHandle=busAssignBlkPortHandles.Inport(assignListIdx+1);
            assignmentInportObj=get_param(assignmentInportHandle,'Object');
            assignmentSigHier=get_param(assignmentInportHandle,'SignalHierarchy');


            busElementName=listOfAssign{assignListIdx};

            [srcPortHandles,targetSrcInfos]=findBusElementSrc(h,busElementName,virBusSource,assignmentSigHier);


            if(assignmentInportObj.CompiledPortBusMode==1)

                replacementSource=assignmentInportObj.getActualSrcForVirtualBus;
            else
                replacementSource=assignmentInportObj.getActualSrc;
            end

            [replacePortHandles,replaceSrcInfos]=findBusElementSrc(h,[],replacementSource,assignmentSigHier);

            for idx=1:length(srcPortHandles)
                srcPortHandle=srcPortHandles{idx};
                replacePortHandle=replacePortHandles{idx};
                if(isempty(srcPortHandle)||isempty(replacePortHandle))
                    continue;
                end


                srcPortObj=get_param(srcPortHandle,'Object');
                [srcSigID.blkObj,srcSigID.pathItem,srcSigID.srcInfo]=...
                getSourceSignal(h,srcPortObj,true);

                if~isempty(targetSrcInfos)
                    targetSrcInfo=targetSrcInfos{idx};
                    if~isempty(targetSrcInfo)&&targetSrcInfo.srcBusElIdx~=-1
                        srcSigID.srcInfo=targetSrcInfo;
                    end
                end
                if isempty(srcSigID.blkObj)||isempty(srcSigID.pathItem)
                    continue;
                end


                replacePortObj=get_param(replacePortHandle,'Object');
                [repSigID.blkObj,repSigID.pathItem,repSigID.srcInfo]=...
                getSourceSignal(h,replacePortObj,true);
                if isempty(repSigID.blkObj)||isempty(repSigID.pathItem)
                    continue;
                end
                if~isempty(replaceSrcInfos)
                    replaceSrcInfo=replaceSrcInfos{idx};
                    if~isempty(replaceSrcInfo)&&replaceSrcInfo.srcBusElIdx~=-1
                        repSigID.srcInfo=replaceSrcInfo;
                    end
                end


                oneList={srcSigID,repSigID};
                sharedLists=h.hAppendToSharedLists(sharedLists,oneList);
            end
        end
    end

end

function[srcPortHandles,srcInfos]=findBusElementSrc(h,busElementName,virBusSource,sigHier)

    srcPortHandles=[];
    srcInfos=[];

    currentMap=virBusSource;
    levelNotFound=false;

    if(~isempty(busElementName))
        hierLevels=regexp(busElementName,'\.','split');

        for levelIdx=1:length(hierLevels)
            levelName=hierLevels{levelIdx};
            hasKey=isa(currentMap,'containers.Map')&&currentMap.isKey(levelName);
            if hasKey
                currentMap=currentMap(levelName);
            else
                levelNotFound=true;
                break;
            end
        end
    end

    if~levelNotFound
        if(isa(currentMap,'containers.Map'))
            leafInfo=getMapLeafNodes(currentMap,sigHier);
        else
            leafInfo={currentMap};
        end
        for leafIndex=1:length(leafInfo)
            currentLeafInfo=leafInfo{leafIndex};
            srcPortHandles{leafIndex}=currentLeafInfo(1,1);%#ok<AGROW>
            if size(currentLeafInfo,2)>3&&currentLeafInfo(1,4)~=-1
                srcPortObj=get_param(srcPortHandles{leafIndex},'Object');
                attributes=srcPortObj.getCompiledAttributes(currentLeafInfo(1,4));
                srcInfos{leafIndex}.busObjectName=h.hCleanDTOPrefix(attributes.parentBusObjectName);%#ok<AGROW>
                srcInfos{leafIndex}.busElementName=attributes.eName;%#ok<AGROW>
                srcInfos{leafIndex}.srcBusElIdx=currentLeafInfo(1,4);%#ok<AGROW>
            else
                srcInfos{leafIndex}=[];%#ok<AGROW>
            end
        end
    end

end

function leafInfo=getMapLeafNodes(currentMap,sigHier)

    leafInfo={};

    orderedNames=getSigNamesFromSigHier(sigHier);

    for keyIdx=1:length(orderedNames)
        currentChildMap=currentMap(orderedNames{keyIdx});
        if(isa(currentChildMap,'containers.Map'))
            childSigHier=sigHier.Children(keyIdx);
            leafInfo=[leafInfo,getMapLeafNodes(currentChildMap,childSigHier)];%#ok<AGROW>
        else
            leafInfo=[leafInfo,currentChildMap];%#ok<AGROW>
        end
    end
end

function orderedKeys=getSigNamesFromSigHier(sh)
    orderedKeys={};
    for i=1:numel(sh.Children)
        thisChild=sh.Children(i);
        orderedKeys{i}=thisChild.SignalName;%#ok<AGROW>
    end
end