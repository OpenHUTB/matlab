function dstH=getDestinationBlock(blockH)












    dstH=-1;

    try
        portHandles=get_param(blockH,'PortHandles');
        outportH=portHandles.Outport;
        if(numel(outportH)==1)
            eiInitVal=slfeature('EngineInterface',Simulink.EngineInterfaceVal.byFiat);
            eiCleanup=onCleanup(@()slfeature('EngineInterface',eiInitVal));
            outportObj=get(outportH,'Object');
            actDstPortHTemp=outportObj.getActualDst;
            actDstPortH=actDstPortHTemp(:,1);
            dstH=get(actDstPortH,'ParentHandle');
            if iscell(dstH)
                dstH=cell2mat(dstH);
            end
            bType=get_param(dstH,'BlockType');
            hiddenToWks_Idx=strcmpi(get_param(dstH,'Hidden'),'on')&...
            (strcmpi(bType,'ToWorkspace')|strcmpi(bType,'ToAsyncQueueBlock'));
            dstH(hiddenToWks_Idx)=[];
            if(numel(dstH)==1)
                if isConnectedThroughAtomicSubsys(blockH,dstH)
                    dstH=-1;
                end
            else
                dstH=-1;
            end
        end
    catch
        dstH=-1;
    end


    function result=isConnectedThroughAtomicSubsys(srcH,dstH)



        result=false;
        srcParent=get_param(srcH,'Parent');
        dstParent=get_param(dstH,'Parent');


        if strcmp(srcParent,dstParent)
            return
        end

        srcParentParts=strsplit(srcParent,'/');
        dstParentParts=strsplit(dstParent,'/');
        numSrcLevels=length(srcParentParts);
        numDstLevels=length(dstParentParts);
        minLevels=min(numSrcLevels,numDstLevels);

        diffLevel=[];
        for i=1:minLevels

            if~strcmp(srcParentParts{i},dstParentParts{i})
                diffLevel=i;
                break;
            end
        end



        if isempty(diffLevel)
            diffLevel=minLevels+1;
        end



        for i=diffLevel:numSrcLevels
            subsys=strjoin(srcParentParts(1:i),'/');
            if strcmpi(get_param(subsys,'IsSubsystemVirtual'),'off')
                result=true;
                return;
            end
        end



        for i=diffLevel:numDstLevels
            subsys=strjoin(dstParentParts(1:i),'/');
            if strcmpi(get_param(subsys,'IsSubsystemVirtual'),'off')
                result=true;
                return;
            end
        end

