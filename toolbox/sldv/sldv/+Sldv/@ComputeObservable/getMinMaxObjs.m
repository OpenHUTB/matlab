function status=getMinMaxObjs(obj,MdlIdx,BlkIdx)




    status=true;

    blkSt=obj.CovDependency(MdlIdx).Dependency(BlkIdx);
    blkH=obj.getHandle(blkSt.BlkName);
    blkSid=blkSt.BlkName;
    outPortNo=1;

    numInPort=length(blkSt.blkInputDependency);
    minMaxCompose=[];




    if(numInPort==1)&&...
        obj.isBaseObjectiveBlock(MdlIdx,BlkIdx)
        return;
    end

    for i=1:numInPort
        minMaxPick{i}.elem=Sldv.ObjectiveSelection.sldvPickObjectives(...
        blkH,'covtype','blkcov','portId',i);%#ok<*AGROW>




        minMaxPick{i}.pathList=struct('sid',blkSid,'port',i,...
        'inValues',[],'outValues',[]);


        for j=1:numInPort
            minMaxPick{i}.pathList.inValues{j}=['inp',num2str(j)];
        end
        minMaxPick{i}.pathList.outValues{1}=['inp',num2str(i)];

        minMaxPick{i}.value='';
        minMaxPick{i}.outValue='';
    end

    if obj.isBaseObjectiveBlock(MdlIdx,BlkIdx)
        for i=1:numInPort
            minMaxPortCompose{i}=Sldv.ObjectiveSelection.sldvCompose(minMaxPick{i});
            minMaxCompose=[minMaxCompose,minMaxPortCompose{i}];
        end
    else
        for i=1:numInPort
            srcObjList=obj.getObjectiveList(MdlIdx,BlkIdx,i);
            minMaxPortCompose{i}=Sldv.ObjectiveSelection.sldvGroupCompose(srcObjList,minMaxPick{i});
            minMaxCompose=[minMaxCompose,minMaxPortCompose{i}];
        end
    end
    obj.addBlkOutputSpec(MdlIdx,BlkIdx,outPortNo,minMaxCompose);
end
