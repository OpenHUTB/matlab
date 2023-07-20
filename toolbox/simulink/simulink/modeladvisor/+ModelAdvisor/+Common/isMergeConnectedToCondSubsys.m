function[isCndSubSysFlag,srcBlk]=isMergeConnectedToCondSubsys(mergeBlk)


















    blockType=struct('Inport',1,'Subsystem',2,'ModelReference',3,'From',4);

    inCnctInfo=findInPortsOfMerge(mergeBlk);

    for outPortCount=1:length(inCnctInfo)
        isCndSubSysFlag=false;
        srcBlk=inCnctInfo(outPortCount).SrcBlock;

        mergeLineHandles=get_param(mergeBlk,'Linehandles');
        currentLineHandle=mergeLineHandles.Inport(outPortCount);









        while~isCndSubSysFlag...
            &&~isempty(currentLineHandle)...
            &&currentLineHandle~=-1




            if isempty(srcBlk)||...
                (isnumeric(srcBlk)&&~ishandle(srcBlk))

                srcBlk=DAStudio.message('ModelAdvisor:jmaab:jc_0659_disconnectedInput');
                break;

            end

            cnd=findBlockType(srcBlk);

            if cnd==blockType.Inport





                srcBlkParent=get_param(srcBlk,'Parent');
                srcBlkParentObj=get_param(srcBlkParent,'Object');

                if isa(srcBlkParentObj,'Simulink.BlockDiagram')
                    isCndSubSysFlag=true;
                    break;
                end






                [srcBlk,currentLineHandle]=getSrcBlkForSubSystemInPort(srcBlk,currentLineHandle);

            elseif cnd==blockType.Subsystem





                isCndSubSysFlag=isConditionallyExecuted(srcBlk);


                if isCndSubSysFlag
                    break;
                end







                if Stateflow.SLUtils.isStateflowBlock(srcBlk)
                    break;
                end


                [srcBlkNext,currentLineHandle]=getSrcBlkForSubSystemOutPut(srcBlk,currentLineHandle);



                if isempty(srcBlkNext)
                    break;
                else
                    srcBlk=srcBlkNext;
                end






                cnd=findBlockType(srcBlk);

                if cnd==blockType.Inport
                    srcBlk=get_param(srcBlk,'Parent');
                    break;
                end

            elseif cnd==blockType.ModelReference

                isCndSubSysFlag=isConditionallyExecuted(srcBlk);
                break;

            elseif cnd==blockType.From

                [srcBlk,currentLineHandle]=getFromGotoSrcBlock(srcBlk);

            else

                break;
            end


        end

        if~isCndSubSysFlag


            break;

        end
    end
end


function inCnctInfo=findInPortsOfMerge(blk)








    cnctInfo=get_param(blk,'PortConnectivity');
    flags=false(1,length(cnctInfo));
    for count=1:length(cnctInfo)
        if~isempty(cnctInfo(count).SrcBlock)
            flags(count)=true;
        end
    end
    inCnctInfo=cnctInfo(flags);
end


function flag=isConditionallyExecuted(blk)










    flag=false;
    blkObj=get_param(blk,'Object');

    srcBlkPortHdl=blkObj.PortHandles;
    conditionalTPorts=[srcBlkPortHdl.Enable...
    ,srcBlkPortHdl.Trigger...
    ,srcBlkPortHdl.Ifaction];


    evenListenerHdl=blkObj.find('-isa','Simulink.EventListener','-depth',1);

    if~isempty(conditionalTPorts)||~isempty(evenListenerHdl)
        flag=true;
    end

end

function cnd=findBlockType(eHdl)






    if strcmp(get_param(eHdl,'BlockType'),'Inport')
        cnd=1;
    elseif strcmp(get_param(eHdl,'BlockType'),'SubSystem')
        cnd=2;
    elseif strcmp(get_param(eHdl,'BlockType'),'ModelReference')
        cnd=3;
    elseif strcmp(get_param(eHdl,'BlockType'),'From')
        cnd=4;
    else
        cnd=5;
    end
end


function[srcBlock,newLineHandle]=getFromGotoSrcBlock(currentBlk)


    gotoBOjStruct=get_param(currentBlk,'GotoBlock');

    if isempty(gotoBOjStruct.handle)
        srcBlock=[];
        return;
    end

    srcBlock=gotoBOjStruct.handle;
    newLineHandleInfo=get_param(srcBlock,'Linehandles');
    newLineHandle=newLineHandleInfo.Inport;

    cnctInfo=get_param(srcBlock,'PortConnectivity');
    srcBlock=cnctInfo.SrcBlock;

end

function[srcBlock,newLineHandle]=getSrcBlkForSubSystemOutPut(currentBlk,currentLineHandle)














    srcBlock=[];
    newLineHandle=[];

    srcPortHdl=get_param(currentLineHandle,'SrcPortHandle');
    portNumber=get_param(srcPortHdl,'PortNumber');
    outPorts=find_system(currentBlk,...
    'SearchDepth',1,'LookUnderMasks','on',...
    'BlockType','Outport');
    if~isempty(outPorts)
        for portCount=1:numel(outPorts)
            if str2double(get_param(outPorts(portNumber),'Port'))==portNumber
                srcBlock=outPorts(portNumber);


                break;
            end
        end

        newLineHandleInfo=get_param(srcBlock,'Linehandles');
        newLineHandle=newLineHandleInfo.Inport;

        cnctInfo=get_param(srcBlock,'PortConnectivity');
        srcBlock=cnctInfo.SrcBlock;
    end
end

function[srcBlock,newLineHandle]=getSrcBlkForSubSystemInPort(currentBlk,currentLineHandle)















    srcBlkHdl=get_param(currentLineHandle,'SrcBlockHandle');
    portNumber=str2double(get_param(srcBlkHdl,'Port'));
    parentBlk=get_param(currentBlk,'Parent');
    portHandles=get_param(parentBlk,'PortHandles');
    cnctInfo=get_param(parentBlk,'PortConnectivity');

    for pHCount=1:length(portHandles.Inport)
        if portNumber==get_param(portHandles.Inport(pHCount),'PortNumber')
            srcBlock=cnctInfo(pHCount).SrcBlock;
            break;


        end
    end
    lineHandleInfo=get_param(parentBlk,'LineHandles');
    newLineHandle=lineHandleInfo.Inport(pHCount);

end
