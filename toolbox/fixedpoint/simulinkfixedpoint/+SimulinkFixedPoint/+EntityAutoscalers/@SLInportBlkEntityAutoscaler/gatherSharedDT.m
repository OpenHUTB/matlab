function sharedLists=gatherSharedDT(h,blkObj)



    sharedLists={};

    ph=blkObj.PortHandles;
    if~isempty(ph)&&~isempty(ph.Outport(1))




        if(hIsVirtualBus(h,ph.Outport(1)))

            if strcmp(get_param(blkObj.Handle,'virtual'),'on')

                return;

            else
                if strcmp(blkObj.Parent,bdroot(blkObj.Parent))

                    return;
                end




                portNumb=str2double(blkObj.Port);


                ph=get_param(blkObj.Parent,'PortHandles');
                portObj=get_param(ph.Inport(portNumb),'Object');
                oneList=getAllSourceSignal(h,portObj,false);
                if~isempty(oneList)
                    structSignalID.blkObj=blkObj;
                    structSignalID.pathItem='1';
                    oneList{end+1}=structSignalID;
                    sharedLists{1}=oneList;
                end

                return;
            end

        end
    end

    newList=sameDataTypeForSpecificPorts(h,blkObj);
    if~isempty(newList)
        sharedLists{end+1}=newList;
    end



    function sharedListPorts=sameDataTypeForSpecificPorts(h,blk)

        sharedListPorts={};

        if~isa(get_param(blk.Parent,'Object'),'Simulink.BlockDiagram')
            isSubsysInport=~isempty(blk.getActualSrc);
        else
            return;
        end

        if isSubsysInport
            [structSignalID.blkObj,structSignalID.pathItem,...
            structSignalID.srcInfo]=h.getSourceSignal(blk);
        else
            structSignalID.blkObj=[];
        end
        inportSignalID.blkObj=blk;
        inportSignalID.pathItem='1';

        if~isempty(structSignalID.blkObj)&&~isempty(structSignalID.pathItem)
            sharedListPorts={inportSignalID,structSignalID};
        end


