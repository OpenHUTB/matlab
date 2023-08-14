function status=getSwitchObjs(obj,MdlIdx,BlkIdx)




    status=true;
    blkSt=obj.CovDependency(MdlIdx).Dependency(BlkIdx);
    blkH=obj.getHandle(blkSt.BlkName);
    blkSid=blkSt.BlkName;
    outPortNo=1;

    switchCompose=[];
    switchPick{1}.elem=Sldv.ObjectiveSelection.sldvPickObjectives(...
    blkH,'covtype','blkcov','portId',1);
    switchPick{2}(1).elem=Sldv.ObjectiveSelection.sldvPickObjectives(...
    blkH,'covtype','blkcov','portId',2,'outcome',0);
    switchPick{2}(2).elem=Sldv.ObjectiveSelection.sldvPickObjectives(...
    blkH,'covtype','blkcov','portId',2,'outcome',1);
    switchPick{3}.elem=Sldv.ObjectiveSelection.sldvPickObjectives(...
    blkH,'covtype','blkcov','portId',3);

    inValues={'inp1','inp2','inp3'};



    for i=1:3
        for j=1:length(switchPick{i})
            switchPick{i}(j).pathList=struct('sid',blkSid,'port',i);
            switchPick{i}(j).pathList.inValues=inValues;
            switchPick{i}(j).pathList.outValues=['inp',num2str(i)];
            switchPick{i}(j).value='';
            switchPick{i}(j).outValue='';
        end
    end

    if obj.isBaseObjectiveBlock(MdlIdx,BlkIdx)
        for i=1:2:3

            switchCompose{i}=Sldv.ObjectiveSelection.sldvCompose(switchPick{i});%#ok<*AGROW>
        end
    else

        for i=1:3
            srcObjList=obj.getObjectiveList(MdlIdx,BlkIdx,i);

            if~isempty(srcObjList)
                switchCompose{i}=[];
                for j=1:length(srcObjList)
                    srcConstraint=srcObjList(j);
                    srcValue=Sldv.ObjectiveSelection.getConstraintValue(srcConstraint);
                    if~isempty(srcValue)&&(i==2)

                        switchCompose{i}=[switchCompose{i},...
                        Sldv.ObjectiveSelection.addPathInformation(srcConstraint,...
                        switchPick{i}(1).pathList,switchPick{i}(1).outValue)];
                    else
                        for numPick=1:length(switchPick{i})
                            if~isempty(srcValue)
                                switchPick{i}(numPick).pathList.inValues{i}=srcValue;
                                if i~=2
                                    switchPick{i}(numPick).pathList.outValues=srcValue;
                                    switchPick{i}(numPick).outValue=srcValue;
                                end
                            end

                            switchCompose{i}=[switchCompose{i},...
                            Sldv.ObjectiveSelection.sldvCompose(srcConstraint,switchPick{i}(numPick))];

                            switchPick{i}(numPick).pathList.inValues=inValues;
                            if i~=2
                                switchPick{i}(numPick).pathList.outValues=inValues{i};
                                switchPick{i}(numPick).outValue='';
                            end
                        end
                    end
                end
            else
                if(i~=2)
                    switchCompose{i}=Sldv.ObjectiveSelection.sldvCompose(switchPick{i});
                end
            end
        end
    end


    switchOutCompose=[switchCompose{1},switchCompose{2},switchCompose{3}];
    obj.addBlkOutputSpec(MdlIdx,BlkIdx,outPortNo,switchOutCompose);
end
