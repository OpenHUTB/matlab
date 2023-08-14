function blkHandles=IdentSigsWithContTsAndNonFloatDataType(iSystem)









    blkHandles=[];
    subsysHdl=get_param(iSystem,'Handle');
    modelHdl=get_param(bdroot(iSystem),'Handle');
    modelObj=get_param(modelHdl,'object');
    subsysObj=get_param(subsysHdl,'object');
    blkList=modelObj.getSortedList;

    blkListLen=length(blkList)+1;
    while blkListLen>1
        blkListLen=blkListLen-1;
        blk=blkList(blkListLen);
        blkList(blkListLen)=0;


        blkObj=get_param(blk,'object');
        if(subsysHdl~=modelHdl)
            if~isequal(strfind(blkObj.getFullName,subsysObj.getFullName),1)
                continue;
            end
        end
        if blkObj.isSynthesized,continue;end

        if isequal(get_param(blk,'BlockType'),'SubSystem')

            subBlkObj=get_param(blk,'object');
            subBlkList=subBlkObj.getSortedList;



            if sl('is_stateflow_based_block',blk)
                for subIdx=1:length(subBlkList)
                    subBlkListObj=...
                    get_param(subBlkList(subIdx),'object');
                    if isequal(subBlkListObj.BlockType,'S-Function')
                        subBlkList(subIdx)=[];
                        break;
                    end
                end
            end

            blkList=[blkList(1:blkListLen-1);subBlkList];
            blkListLen=length(blkList)+1;
            continue;
        end


        blkST=get_param(blk,'CompiledSampleTime');
        if iscell(blkST)
            blkST=blkST{1};
        end

        if(blkST(1)~=0||blkST(2)~=0),continue;end

        portDT=get_param(blk,'CompiledPortDataTypes');
        pHndls=get_param(blk,'PortHandles');
        opHndls=pHndls.Outport;
        inHndls=pHndls.Inport;





        if(length(opHndls)==1&&length(inHndls)==1)

            opDT=portDT.Outport{1};
            ipDT=portDT.Inport{1};
            if(blkObj.isSampleTimeInherited&&isequal(opDT,ipDT)),...
                continue;
            end
        end

        for idx=1:length(opHndls)
            opDT=portDT.Outport{idx};
            if(isequal(opDT,'single')||isequal(opDT,'double'))
                continue;
            end


            opST=get_param(opHndls(idx),'CompiledPortSampleTime');
            if iscell(opST)
                opST=opST{1};
            end
            if(opST(1)==0&&opST(2)==0)
                parentHandle=get_param(get_param(opHndls(idx),'Parent'),'Handle');
                blkHandles=[parentHandle;blkHandles];%#ok
            end
        end
    end

end
