function status=addInspectionObjectivesToOutport(obj,MdlIdx,BlkIdx)







    status=true;

    blkSt=obj.CovDependency(MdlIdx).Dependency(BlkIdx);
    blkH=obj.getHandle(blkSt.BlkName);
    blkSid=blkSt.BlkName;

    numInPort=length(blkSt.blkInputDependency);
    numOutPort=length(blkSt.blkOutputSpec);
    blockCompose=[];

    [~,~,callPerPort]=sldvprivate('getAccessInfoForObserveFunction',blkH);

    if callPerPort==1||callPerPort==0
        for i=1:numInPort
            blockPick{i}.pathList=struct('sid',blkSid,'port',i);

            blockPick{i}.elem=Sldv.ObjectiveSelection.sldvPickObjectives(...
            blkH,'covtype','blkcov','portId',i,...
            'blockType',0);%#ok<*AGROW>

            blockPortCompose{i}=Sldv.ObjectiveSelection.sldvCompose(...
            blockPick{i});
            blockCompose=[blockCompose,blockPortCompose{i}];
        end

        for j=1:numOutPort
            obj.addBlkOutputSpec(MdlIdx,BlkIdx,j,blockCompose);
        end
    elseif callPerPort==2
        for i=1:numOutPort
            blockPick{i}.pathList=struct('sid',blkSid,'port',i);

            blockPick{i}.elem=Sldv.ObjectiveSelection.sldvPickObjectives(...
            blkH,'covtype','blkcov','portId',i,...
            'blockType',0);%#ok<*AGROW>

            blockPortCompose=Sldv.ObjectiveSelection.sldvCompose(...
            blockPick{i});
            obj.addBlkOutputSpec(MdlIdx,BlkIdx,i,blockPortCompose);
        end
    end
    obj.CovDependency(MdlIdx).Dependency(BlkIdx).num_paths=1;
end
