function status=getRelOpObjs(obj,MdlIdx,BlkIdx)




    status=true;

    blkSt=obj.CovDependency(MdlIdx).Dependency(BlkIdx);
    blkH=obj.getHandle(blkSt.BlkName);
    blkSid=blkSt.BlkName;
    outPortNo=1;



    relOpPick(1).elem=Sldv.ObjectiveSelection.sldvPickObjectives(...
    blkH,'covtype','condition','outcome','true');
    relOpPick(2).elem=Sldv.ObjectiveSelection.sldvPickObjectives(...
    blkH,'covtype','condition','outcome','false');




    for i=1:2
        relOpPick(i).pathList=struct('sid',blkSid,'port',i,...
        'inValues',[],'outValues',[]);
        relOpPick(i).value='';
    end
    relOpPick(1).outValue=1;
    relOpPick(2).outValue=0;

    numInPort=length(blkSt.blkInputDependency);

    relOpCompose=[];
    for i=1:numInPort
        srcObjList=obj.getObjectiveList(MdlIdx,BlkIdx,i);


        relOpPick(i).pathList.port=i;


        relOpCompose=[relOpCompose,...
        Sldv.ObjectiveSelection.sldvGroupCompose(srcObjList,relOpPick(i))];%#ok<*AGROW>
    end

    obj.addBlkOutputSpec(MdlIdx,BlkIdx,outPortNo,relOpCompose);
end

