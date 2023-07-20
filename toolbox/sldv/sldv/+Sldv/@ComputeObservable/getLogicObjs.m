function status=getLogicObjs(obj,MdlIdx,BlkIdx)




    status=true;
    blkSt=obj.CovDependency(MdlIdx).Dependency(BlkIdx);

    blkH=obj.getHandle(blkSt.BlkName);




    blkSid=blkSt.BlkName;
    outPortNo=1;

    blkNonMask=Sldv.ComputeObservable.logicNonMaskingValue(blkH);
    numInPort=length(blkSt.blkInputDependency);
    if blkNonMask
        inValues=ones(numInPort);
    else
        inValues=zeros(numInPort);
    end

    logicCompose=[];

    for i=1:numInPort
        for j=1:2
            logicPick{i}(j).elem=Sldv.ObjectiveSelection.sldvPickObjectives(blkH,...
            'covtype','blkcov','portId',i,'outcome',j-1);%#ok<*AGROW>
            logicPick{i}(j).pathList=struct('sid',blkSid,'port',i,'inValues',[],'outValues',[]);
            logicPick{i}(j).pathList.inValues=inValues;
            logicPick{i}(j).pathList.inValues(i)=j-1;
            output=Sldv.ComputeObservable.computeLogicOutputValue(j-1,blkH);
            logicPick{i}(j).pathList.outValues(1)=output;
            logicPick{i}(j).outValue=output;
        end
        logicPick{i}(1).value='false';
        logicPick{i}(2).value='true';
    end


    for i=1:numInPort
        srcObjList=obj.getObjectiveList(MdlIdx,BlkIdx,i);
        if isempty(srcObjList)
            logicPortCompose{i}=[];
            logicPortCompose{i}=[logicPortCompose{i},...
            Sldv.ObjectiveSelection.sldvCompose(logicPick{i}(1))];

            logicPortCompose{i}=[logicPortCompose{i},...
            Sldv.ObjectiveSelection.sldvCompose(logicPick{i}(2))];
            logicCompose=[logicCompose,logicPortCompose{i}];
            continue;
        end

        logicPortCompose{i}=[];
        for idx=1:length(srcObjList)
            srcConstraint=srcObjList(idx);
            srcValue=Sldv.ObjectiveSelection.getConstraintValue(srcConstraint);
            if~isempty(srcValue)




                logicPortCompose{i}=[logicPortCompose{i},...
                Sldv.ObjectiveSelection.sldvCompose(srcConstraint,logicPick{i}(srcValue+1))];
            else

                logicPortCompose{i}=[logicPortCompose{i},...
                Sldv.ObjectiveSelection.sldvCompose(srcConstraint,logicPick{i}(1))];
                logicPortCompose{i}=[logicPortCompose{i},...
                Sldv.ObjectiveSelection.sldvCompose(srcConstraint,logicPick{i}(2))];
            end
        end
        logicCompose=[logicCompose,logicPortCompose{i}];
    end
    obj.addBlkOutputSpec(MdlIdx,BlkIdx,outPortNo,logicCompose);
end
