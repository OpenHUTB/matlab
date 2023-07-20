classdef(Sealed,Hidden)ZCUtils





    properties(Constant,Access=private)
        BlockParams={'Name','Position','Description','PortSchema','VariantControl'};
        PortBlockParams={'Name','Position','Description','PortName'};
        BusPortBlockParams={'Position','Description','PortName','Element','isClientServer'};
    end


    methods(Static,Hidden)

        function DeletePhysicalLines(portObjs)

            for idx=1:numel(portObjs)
                if numel(portObjs)==1
                    lineHdl=portObjs.Line;
                else
                    lineHdl=portObjs{idx}.Line;
                end
                if ishandle(lineHdl)
                    segObj=get_param(lineHdl,'Object');
                    segs=segObj.lineChildren;
                    if isempty(segs)
                        delete(segObj);
                    else
                        delete(segs);
                    end
                end
            end
        end

        function DeleteConnectedLines(blockH)


            portHdls=get_param(blockH,'PortHandles');

            if~isempty(portHdls.RConn)
                systemcomposer.internal.arch.internal.ZCUtils.DeletePhysicalLines(...
                get_param(portHdls.RConn,'Object'));
            end
            if~isempty(portHdls.LConn)
                systemcomposer.internal.arch.internal.ZCUtils.DeletePhysicalLines(...
                get_param(portHdls.LConn,'Object'));
            end

            todelete=[portHdls.Inport,portHdls.Outport,...
            portHdls.Enable,portHdls.Trigger,...
            portHdls.State,portHdls.Ifaction,...
            portHdls.Reset];
            for i1=1:numel(todelete)
                try
                    delete_line(get_param(todelete(i1),'Line'));
                catch

                end
            end
        end

        function flatPortHandles=GetFlatPortHandles(blkH)


            pH=get_param(blkH,'PortHandles');
            flatPortHandles=[pH.Inport,pH.Outport];
        end

        function connMap=GetConnectionMapping(blkH)















            pFlatH=systemcomposer.internal.arch.internal.ZCUtils.GetFlatPortHandles(blkH);










            pC=get_param(blkH,'PortConnectivity');
            connMap=containers.Map('KeyType','double','ValueType','any');
            if~isempty(pFlatH)
                for i=1:length(pFlatH)
                    if~isempty(pC(i).SrcBlock)&&pC(i).SrcBlock~=-1
                        srcBlkPH=get_param(pC(i).SrcBlock,'PortHandles');

                        if pC(i).SrcPort>=length(srcBlkPH.Outport)
                            assert(length(srcBlkPH.State)==1);
                            pC(i).SrcPort=srcBlkPH.State(1);
                        else
                            portNum=pC(i).SrcPort+1;
                            pC(i).SrcPort=srcBlkPH.Outport(portNum);
                        end
                    end

                    if~isempty(pC(i).DstBlock)
                        for j=1:length(pC(i).DstBlock)
                            if pC(i).DstPort(j)==0||~ishandle(pC(i).DstPort(j))
                                dstBlkH=pC(i).DstBlock(j);
                                dstBlkPH=get_param(dstBlkH,'PortHandles');
                                dstBlkFlatPH=[dstBlkPH.Inport,dstBlkPH.Enable,...
                                dstBlkPH.Trigger,dstBlkPH.Ifaction,...
                                dstBlkPH.Reset];
                                dstPortNum=pC(i).DstPort(j)+1;
                                pC(i).DstPort(j)=dstBlkFlatPH(dstPortNum);
                            end
                        end
                    end
                    connMap(pFlatH(i))=pC(i);
                end
            end
        end


        function ResolveConnections(mdlHandle,blkConnMapBefore)




            srcPorts=systemcomposer.internal.arch.internal.ZCUtils.GetFlatPortHandles(mdlHandle);
            pH=get_param(mdlHandle,'PortHandles');

            srcInports=[pH.Inport];
            srcOutports=[pH.Outport];

            dstPorts=values(blkConnMapBefore);
            if(numel(srcPorts)~=numel(dstPorts))

                return;
            end


            in=1;
            out=1;
            for i=1:numel(dstPorts)
                if(~isempty(dstPorts{i}.DstPort))
                    for j=1:numel(dstPorts{i}.DstPort)
                        add_line(get_param(mdlHandle,'Parent'),srcOutports(out),dstPorts{i}.DstPort(j),'autorouting','on');
                    end
                    out=out+1;
                end
                if(~isempty(dstPorts{i}.SrcPort))
                    add_line(get_param(mdlHandle,'Parent'),dstPorts{i}.SrcPort,srcInports(in),'autorouting','on');
                    in=in+1;
                end
            end
        end

        function blockParams=getBlockParams(blkH)
            import systemcomposer.internal.arch.internal.ZCUtils;
            blockType=get_param(blkH,'BlockType');
            if blockType=="Inport"||blockType=="Outport"
                if get_param(blkH,'isBusElementPort')=="on"
                    paramToCheck=ZCUtils.BusPortBlockParams;
                else
                    paramToCheck=ZCUtils.PortBlockParams;
                end
            else
                paramToCheck=ZCUtils.BlockParams;
            end

            numParams=length(paramToCheck);
            blockParams=cell(1,numParams);
            for prmIdx=1:numParams
                blockParams{prmIdx}=get_param(blkH,paramToCheck{prmIdx});
            end
        end

        function restoreBlockParams(blkH,blockParams)
            import systemcomposer.internal.arch.internal.ZCUtils;
            blockType=get_param(blkH,'BlockType');
            if blockType=="Inport"||blockType=="Outport"
                if get_param(blkH,'isBusElementPort')=="on"
                    paramToRestore=ZCUtils.BusPortBlockParams;
                else
                    paramToRestore=ZCUtils.PortBlockParams;
                end
            else
                paramToRestore=ZCUtils.BlockParams;
            end
            numParams=length(blockParams);
            for prmIdx=1:numParams
                set_param(blkH,paramToRestore{prmIdx},blockParams{prmIdx});
            end
        end
    end

end


