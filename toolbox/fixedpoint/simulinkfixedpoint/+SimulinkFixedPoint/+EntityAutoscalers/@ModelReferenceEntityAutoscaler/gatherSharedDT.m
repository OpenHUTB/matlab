function sharedLists=gatherSharedDT(h,blkObj)




    sharedLists={};

    if blkObj.isPostCompileVirtual()



        return;
    end

    ports=blkObj.Ports;
    inportNum=ports(1);



    for idx=1:inportNum
        curListPorts=h.hShareDTSpecifiedPorts(blkObj,idx,[]);
        if~isempty(curListPorts)
            sharedRec{1}.blkObj=curListPorts{1}.blkObj;
            sharedRec{1}.pathItem=curListPorts{1}.pathItem;
            sharedRec{2}.blkObj=blkObj;
            sharedRec{2}.pathItem=['inport',int2str(idx)];
            sharedLists{end+1}=sharedRec;%#ok<AGROW>
        end
    end


