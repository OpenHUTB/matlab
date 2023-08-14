classdef BlockReplaceUtils<handle






    methods(Static)

        function blkData=getBlkDataAndDeleteLines(blkH)




            import autosar.simulink.bep.BlockReplaceUtils;
            blkData=BlockReplaceUtils.getBlkData(blkH);
            BlockReplaceUtils.deleteConnectedLines(blkH);
        end

        function restoreBlockData(blkH,blkData)





            set_param(blkH,'Position',blkData.Position);


            pH=get_param(blkH,'PortHandles');

            srcInports=[pH.Inport];
            srcOutports=[pH.Outport];

            dstInports=values(blkData.BlkConnMaps.Inports);
            dstOutports=values(blkData.BlkConnMaps.Outports);
            if(numel(srcInports)~=numel(dstInports)||...
                numel(srcOutports)~=numel(dstOutports))

                return;
            end


            for i=1:numel(srcOutports)
                portNumber=get_param(srcOutports(i),'PortNumber');
                dstPort=blkData.BlkConnMaps.Outports(portNumber);
                if(~isempty(dstPort.DstPort))
                    for j=1:numel(dstPort.DstPort)


                        if(get_param(dstPort.DstPort(j),'Line')~=-1)
                            lineH=get_param(dstPort.DstPort(j),'Line');
                        else
                            lineH=add_line(get_param(blkH,'Parent'),srcOutports(i),dstPort.DstPort(j),'autorouting','on');
                        end

                        cachedLineInfo=blkData.BlkConnMaps.OutportLines(portNumber);
                        autosar.simulink.bep.BlockReplaceUtils.setCachedLineInfo(lineH,cachedLineInfo);
                    end
                end
            end
            for i=1:numel(srcInports)
                portNumber=get_param(srcInports(i),'PortNumber');
                dstPort=blkData.BlkConnMaps.Inports(portNumber);
                if(~isempty(dstPort.SrcPort))


                    if(get_param(srcInports(i),'Line')~=-1)
                        lineH=get_param(srcInports(i),'Line');
                    else
                        lineH=add_line(get_param(blkH,'Parent'),dstPort.SrcPort,srcInports(i),'autorouting','on');
                    end

                    cachedLineInfo=blkData.BlkConnMaps.InportLines(portNumber);
                    autosar.simulink.bep.BlockReplaceUtils.setCachedLineInfo(lineH,cachedLineInfo);
                end
            end
        end
    end

    methods(Static,Access=private)
        function setCachedLineInfo(lineH,cachedLineInfo)


            cachedLineInfo=reshape(cachedLineInfo,[2,numel(cachedLineInfo)/2]);
            for lineInfoIdx=1:size(cachedLineInfo,2)
                try
                    set_param(lineH,cachedLineInfo{:,lineInfoIdx});
                catch ME

                    if~strcmp(ME.identifier,'Simulink:blocks:BusSelectorCantChangeSignalLabel')
                        ME.rethrow();
                    end
                end
            end
        end

        function flatPortHandles=getFlatPortHandles(blkH)


            pH=get_param(blkH,'PortHandles');
            flatPortHandles=[pH.Inport,pH.Outport];
        end

        function deleteConnectedLines(blkH)


            linesH_orig=get_param(blkH,'PortHandles');
            todelete=[linesH_orig.Inport,linesH_orig.Outport,...
            linesH_orig.Enable,linesH_orig.Trigger,...
            linesH_orig.State,linesH_orig.LConn,...
            linesH_orig.RConn,linesH_orig.Ifaction,...
            linesH_orig.Reset];
            for i1=1:numel(todelete)
                try
                    delete_line(get_param(todelete(i1),'Line'));
                catch

                end
            end
        end

        function blkData=getBlkData(blkH)



            import autosar.simulink.bep.BlockReplaceUtils;

            blkData.BlkConnMaps=...
            BlockReplaceUtils.getConnectionMapping(blkH);

            blkData.Position=get_param(blkH,'Position');
        end

        function connMaps=getConnectionMapping(blkH)



            import autosar.simulink.bep.BlockReplaceUtils;













            pFlatH=autosar.simulink.bep.BlockReplaceUtils.getFlatPortHandles(blkH);










            pC=get_param(blkH,'PortConnectivity');

            inportConnMap=containers.Map('KeyType','double','ValueType','any');
            outportConnMap=containers.Map('KeyType','double','ValueType','any');
            inportLineMap=containers.Map('KeyType','double','ValueType','any');
            outportLineMap=containers.Map('KeyType','double','ValueType','any');
            connMaps=struct('Inports',[],'Outports',[],...
            'InportLines',[],'OutportLines',[]);

            for i=1:length(pFlatH)
                if~isempty(pC(i).SrcBlock)
                    if pC(i).SrcBlock~=-1
                        srcBlkPH=get_param(pC(i).SrcBlock,'PortHandles');

                        if pC(i).SrcPort>=length(srcBlkPH.Outport)
                            assert(length(srcBlkPH.State)==1);
                            pC(i).SrcPort=srcBlkPH.State(1);
                        else
                            portNum=pC(i).SrcPort+1;
                            pC(i).SrcPort=srcBlkPH.Outport(portNum);
                        end
                    end
                    inportConnMap(get_param(pFlatH(i),'PortNumber'))=pC(i);

                    cachedLineInfo=BlockReplaceUtils.cacheLineInfo(pFlatH(i));
                    inportLineMap(get_param(pFlatH(i),'PortNumber'))=cachedLineInfo;
                end

                if~isempty(pC(i).DstBlock)||size(pC(i).DstBlock,1)
                    for j=1:length(pC(i).DstBlock)
                        dstPort=pC(i).DstPort(j);









                        if dstPort==0||~(ishandle(dstPort)&&~ishghandle(dstPort))
                            dstBlkH=pC(i).DstBlock(j);
                            dstBlkPH=get_param(dstBlkH,'PortHandles');
                            dstBlkFlatPH=[dstBlkPH.Inport,dstBlkPH.Enable,...
                            dstBlkPH.Trigger,dstBlkPH.Ifaction,...
                            dstBlkPH.Reset];
                            dstPortNum=pC(i).DstPort(j)+1;
                            pC(i).DstPort(j)=dstBlkFlatPH(dstPortNum);
                        end
                    end
                    outportConnMap(get_param(pFlatH(i),'PortNumber'))=pC(i);

                    cachedLineInfo=BlockReplaceUtils.cacheLineInfo(pFlatH(i));
                    outportLineMap(get_param(pFlatH(i),'PortNumber'))=cachedLineInfo;
                end
            end
            connMaps.Inports=inportConnMap;
            connMaps.Outports=outportConnMap;
            connMaps.InportLines=inportLineMap;
            connMaps.OutportLines=outportLineMap;
        end

        function cachedLineInfo=cacheLineInfo(portHandle)


            cachedLineInfo=[];


            lineH=get_param(portHandle,'Line');

            if lineH==-1

                return;
            end

            lineParams=get_param(lineH,'ObjectParameters');
            rawParamNames=fieldnames(lineParams);
            cachedLineInfo={};
            for idx=1:length(rawParamNames)
                thisPrm=rawParamNames{idx};
                isReadWrite=any(strcmp('read-write',lineParams.(thisPrm).Attributes));
                isListType=strcmp(lineParams.(thisPrm).Type,'list');
                if isReadWrite&&~isListType

                    cachedLineInfo{end+1}=thisPrm;%#ok<AGROW>
                    cachedLineInfo{end+1}=get_param(lineH,thisPrm);%#ok<AGROW>
                end
            end
        end
    end
end



