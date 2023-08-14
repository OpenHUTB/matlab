






function[paramStruct,slicerObj]=getParametersAffectingBlock(obj,block,includeIndirect)
    import slslicer.internal.ParameterDependenceInfo.isIndirectUser;

    isBlockValid(block,obj.model,obj.modelRefs);


    existingStartingPoints=obj.slicerObj.StartingPoint;
    if~isempty(existingStartingPoints)
        obj.slicerObj.removeStartingPoint(existingStartingPoints);
    end

    SID=Simulink.ID.getSID(block);
    obj.slicerObj.addStartingPoint(SID);

    obj.slicerObj.SignalPropagation='upstream';
    obj.slicerObj.compute();


    activeBlocks=obj.slicerObj.ActiveBlocks;

    slicerObj=obj.slicerObj;
    paramStruct=obj.paramInfo.getParametersUsedByBlocks(activeBlocks,block,includeIndirect);
end

function isBlockValid(block,model,modelRefs)

    try

        type=get_param(block,'Type');
    catch
        error('Sldv:DebugUsingSlicer:InvalidBlock',getString(message('Sldv:DebugUsingSlicer:InvalidBlock')));
    end
    blockName=getfullname(block);

    blockRoot=bdroot(blockName);
    modelName=getfullname(model);
    if~strcmp(type,'block')||strcmp(blockName,modelName)||~any(ismember(modelRefs,blockRoot))
        error('Sldv:DebugUsingSlicer:InvalidBlock',getString(message('Sldv:DebugUsingSlicer:InvalidBlock')));
    end
end
