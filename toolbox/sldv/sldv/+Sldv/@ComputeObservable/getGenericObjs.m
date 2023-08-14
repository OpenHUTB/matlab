

























function getGenericObjs(obj,MdlIdx,BlkIdx)

    blkSt=obj.CovDependency(MdlIdx).Dependency(BlkIdx);
    blkH=obj.getHandle(blkSt.BlkName);
    blkSid=blkSt.BlkName;

    numInPort=length(blkSt.blkInputDependency);
    numOutPort=length(blkSt.blkOutputSpec);
    blockCompose=[];


    Sldv.ComputeObservable.logDebugMsgs("ComputeObservable","getGenericObjs",...
    "Getting Inspection/Intermediate condition for block :: "+Sldv.ComputeObservable.getBlkName(blkH));



    for i=1:numInPort
        blockPick{i}.pathList=struct('sid',blkSid,'port',i);

    end




    if obj.customValues.AllBlocksInspection||...
        ~isempty(find(strcmp(obj.customValues.InspectionBlocks,blkSid),1))

        Sldv.ComputeObservable.logDebugMsgs("ComputeObservable","getGenericObjs",...
        "Adding Inspection Objectives to Outport for block :: "+Sldv.ComputeObservable.getBlkName(blkH));

        obj.addInspectionObjectivesToOutport(MdlIdx,BlkIdx);
    end

    [~,~,callPerPort]=sldvprivate('getAccessInfoForObserveFunction',blkH);
    if callPerPort==1||callPerPort==0

        for i=1:numInPort

            if obj.portSpecificStop(blkH,i)
                continue;
            end

            srcObjList=obj.getPathObjectiveListToPass(MdlIdx,BlkIdx,i);

            if isempty(srcObjList)


                if isempty(find(strcmp(obj.customValues.InspectionBlocks,blkSid),1))&&...
                    ~obj.customValues.AllBlocksInspection



                    blockPick{i}.elem=Sldv.ObjectiveSelection.sldvPickObjectives(...
                    blkH,'covtype','blkcov','portId',i,...
                    'blockType',0);%#ok<*AGROW>

                    Sldv.ComputeObservable.logDebugMsgs("ComputeObservable","getGenericObjs",...
                    "Picking Inspection Objectives for block :: "+Sldv.ComputeObservable.getBlkName(blkH)+" Inport :: "+i);
                else
                    continue;
                end
            else


                blockPick{i}.elem=Sldv.ObjectiveSelection.sldvPickObjectives(...
                blkH,'covtype','blkcov','portId',i,...
                'blockType',1);%#ok<*AGROW>

                Sldv.ComputeObservable.logDebugMsgs("ComputeObservable","getGenericObjs",...
                "Picking Intermediate Objectives for block :: "+Sldv.ComputeObservable.getBlkName(blkH)+" Inport :: "+i);
            end

            blockPortCompose{i}=Sldv.ObjectiveSelection.sldvGroupCompose(...
            srcObjList,...
            blockPick{i});
            blockCompose=[blockCompose,blockPortCompose{i}];
        end

        for j=1:numOutPort
            obj.addBlkOutputSpec(MdlIdx,BlkIdx,j,blockCompose);
        end
    elseif callPerPort==2
        if~obj.stopPathAtInportsOfBlock(blkH)
            for i=1:numInPort


                srcObjList=obj.getPathObjectiveListToPass(MdlIdx,BlkIdx,i);
                if~isempty(srcObjList)
                    for j=1:numOutPort
                        blockPick{i}.elem=Sldv.ObjectiveSelection.sldvPickObjectives(...
                        blkH,'covtype','blkcov','portId',j,...
                        'blockType',1);%#ok<*AGROW>

                        blockPortCompose=Sldv.ObjectiveSelection.sldvGroupCompose(...
                        srcObjList,...
                        blockPick{i});

                        obj.addBlkOutputSpec(MdlIdx,BlkIdx,j,blockPortCompose);
                    end
                end
            end
        end
    end
end
