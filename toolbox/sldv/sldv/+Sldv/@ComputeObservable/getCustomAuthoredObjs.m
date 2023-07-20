


function getCustomAuthoredObjs(obj,MdlIdx,BlkIdx)


    blkSt=obj.CovDependency(MdlIdx).Dependency(BlkIdx);
    blkSid=blkSt.BlkName;

    blockPick.pathList=struct('sid',blkSid,'port',1);
    blockPick.elem=Sldv.ObjectiveSelection.sldvPickObjectives(...
    getCustomConditionSID(blkSid),'covtype','','portId',1,...
    'blockType',-1);
    blockCompose=Sldv.ObjectiveSelection.sldvCompose(blockPick);

    obj.addBlkOutputSpec(MdlIdx,BlkIdx,1,blockCompose);
end

function actualBlkH=getCustomConditionSID(blkH)


    path=[get_param(blkH,'parent'),'/',get_param(blkH,'Name'),'/viewdvc/customAVTBlockSFcn'];
    actualBlkH=Simulink.ID.getSID(path);
end
