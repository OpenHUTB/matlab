function inputGroups=getInputGroups(blkObj,autoscaler,key2gID)







    inportObjs=get_param(blkObj.PortHandles.Inport,'Object');
    if~iscell(inportObjs)
        inportObjs={inportObjs};
    end

    inputGroups=cell(1,length(inportObjs));
    inputGroups(:)={-1};
    for inportIndex=1:length(inportObjs)
        inportObj=inportObjs{inportIndex};
        srcInfos=autoscaler.getAllSourceSignal(inportObj,false);
        if~isempty(srcInfos)



            srcInfo=srcInfos{1};
            srcGroupId=cpopt.internal.getGroupId(srcInfo.blkObj,srcInfo.pathItem,key2gID);
            inputGroups{inportIndex}=srcGroupId;
        end
    end
end