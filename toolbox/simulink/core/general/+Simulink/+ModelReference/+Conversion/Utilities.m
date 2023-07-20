


classdef Utilities<handle
    properties(Constant)
        ModelFileExtension=['.',get_param(0,'ModelFileFormat')]
        BasicFindOptions={'FollowLinks','on','LookUnderMasks','all','IncludeCommented','off'};
    end

    methods(Static,Access=public)
        function data=cellify(data)
            if~iscell(data)
                data={data};
            end
        end

        function results=isSubsystem(subsys)
            results=arrayfun(@(currentSystem)slInternal('isSubsystem',currentSystem),subsys);
        end


        function cleanupModel(modelName)
            close_system(modelName,0);
            fileName=strcat(modelName,Simulink.ModelReference.Conversion.Utilities.ModelFileExtension);
            Simulink.ModelReference.Conversion.FileUtils.deleteFile(fileName);
        end


        function strbuf=cellstr2str(list,startChar,stopChar)
            N=length(list);
            commaStr='';
            strbuf=startChar;
            for idx=1:N
                strbuf=[strbuf,commaStr,'''',list{idx},''''];%#ok
                commaStr=', ';
            end
            strbuf=[strbuf,stopChar];
        end


        function results=getSubsystemChecksum(subsys)

            results=get_param(subsys,'SID');
        end

        function result=rmiLicenseAvailable()
            [rmiInstalled,rmiLicensed]=rmi.isInstalled();
            result=rmiInstalled&&rmiLicensed;
        end

        function copyRMItoModel(subsysH,modelHandle)
            reqs=rmi.getReqs(subsysH);
            if isempty(reqs)||all(~[reqs.linked])
                return;
            end

            rmi.objCopy(modelHandle,rmi.reqs2str(reqs),modelHandle,false);


            set_param(modelHandle,'hasReqInfo','on');


            rmidata.storageModeCache('set',modelHandle,false);
        end


        function copyRMItoModelBlock(modelRefHandle,modelBlockHandle)
            reqs=rmi.getReqs(modelRefHandle);
            if isempty(reqs)||all(~[reqs.linked])
                return;
            end

            topModel=bdroot(modelBlockHandle);
            if rmidata.isExternal(topModel)
                rmidata.objCopy(modelBlockHandle,reqs,topModel,false);
            else
                rmi.objCopy(modelBlockHandle,rmi.reqs2str(reqs),topModel,false);
            end
        end

        function busNames=getBusNamesFromCompiledIOInfo(compIOInfo)
            mask=arrayfun(@(portInfo)~isempty(portInfo.busName),compIOInfo);
            busNames=arrayfun(@(portInfo)portInfo.busName,compIOInfo(mask),'UniformOutput',false);
        end

        function subsys=getHandles(subsys)
            if~all(ishandle(subsys))
                if ischar(subsys)
                    subsys=get_param(subsys,'Handle');
                elseif iscell(subsys)
                    subsys=cellfun(@(ss)get_param(ss,'Handle'),subsys);
                else
                    assert(false,'Input parameters are not valid block names or handles!')
                end
            end
        end









        function status=isChild(dataStoreName,parentBlocks)
            status=any(cellfun(@(subsys)strncmp(dataStoreName,subsys,length(subsys))&&dataStoreName(length(subsys)+1)~='/',parentBlocks));
        end


        function blocks=findRootLevelPortBlocks(sysH,blockType)
            inputArgs=horzcat({'SearchDepth',1},{'MatchFilter',@Simulink.match.allVariants},Simulink.ModelReference.Conversion.Utilities.BasicFindOptions,{'BlockType',blockType});
            blocks=find_system(sysH,inputArgs{:});
        end

        function subsystemPortBlocks=getSystemPortBlocks(subsysH)
            subsystemPortBlocks.inportBlksH.blocks=Simulink.ModelReference.Conversion.Utilities.findRootLevelPortBlocks(subsysH,'Inport');
            subsystemPortBlocks.outportBlksH.blocks=Simulink.ModelReference.Conversion.Utilities.findRootLevelPortBlocks(subsysH,'Outport');
            subsystemPortBlocks.triggerBlksH.blocks=Simulink.ModelReference.Conversion.Utilities.findRootLevelPortBlocks(subsysH,'TriggerPort');
            subsystemPortBlocks.enableBlksH.blocks=Simulink.ModelReference.Conversion.Utilities.findRootLevelPortBlocks(subsysH,'EnablePort');
            subsystemPortBlocks.resetBlksH.blocks=Simulink.ModelReference.Conversion.Utilities.findRootLevelPortBlocks(subsysH,'ResetPort');
            subsystemPortBlocks.fromBlksH.blocks=Simulink.ModelReference.Conversion.Utilities.findRootLevelPortBlocks(subsysH,'From');
            subsystemPortBlocks.gotoBlksH.blocks=Simulink.ModelReference.Conversion.Utilities.findRootLevelPortBlocks(subsysH,'Goto');

            assert(isempty(subsystemPortBlocks.triggerBlksH.blocks)||length(subsystemPortBlocks.triggerBlksH.blocks)==1);
            assert(isempty(subsystemPortBlocks.enableBlksH.blocks)||length(subsystemPortBlocks.enableBlksH.blocks)==1);
            assert(isempty(subsystemPortBlocks.resetBlksH.blocks)||length(subsystemPortBlocks.resetBlksH.blocks)==1);
        end




        function[width,height]=computePortSize(subsys)
            inports=find_system(subsys,'SearchDepth',1,'LookUnderMasks','all','BlockType','Inport');
            outports=find_system(subsys,'SearchDepth',1,'LookUnderMasks','all','BlockType','Outport');
            ports=vertcat(inports,outports);
            if~isempty(ports)
                pos=get_param(ports(1),'Position');
                width=pos(3)-pos(1);
                height=pos(4)-pos(2);
            else
                width=20;
                height=20;
            end
        end

        function ph=getInportBlock(blk)
            portHandles=get_param(blk,'PortHandles');
            ph=portHandles.Outport;
        end

        function ph=getOutportBlock(blk)
            portHandles=get_param(blk,'PortHandles');
            ph=portHandles.Inport;
        end

        function status=canCopyContent(subsys)
            ssType=Simulink.SubsystemType(subsys);
            status=~(ssType.isSimulinkFunction||ssType.isIteratorSubsystem||ssType.isStateflowSubsystem||ssType.isVariantSubsystem||ssType.isResettableSubsystem);
        end


        function breakLinks(subsys)
            parent=get_param(subsys,'Parent');
            if~isempty(parent)
                Simulink.ModelReference.Conversion.Utilities.breakLinks(parent);
                set_param(subsys,'LinkStatus','none');
            end
        end

        function status=isChildBlock(subsys,blk)
            status=false;
            parent=get_param(blk,'Parent');
            while(~isempty(parent))
                parentH=get_param(parent,'Handle');
                if(parentH==subsys)
                    status=true;
                    break;
                else
                    parent=get_param(parentH,'Parent');
                end
            end
        end

        function randomizePortNames(ports)
            N=numel(ports);
            for idx=1:N
                set_param(ports(idx),'Name',Simulink.ModelReference.Conversion.Utilities.getARandomName());
            end
        end

        function blkName=getARandomName()
            blkName=['temp_',num2str(tic)];
        end

        function[disViewers,disAxes]=disconnectViewers(outport)
            disViewers=[];
            disAxes=[];


            viewers=Simulink.scopes.ViewerUtil.GetPortViewers(outport,'viewer');
            if~isempty(viewers)

                viewerHValues=viewers.values;
                for i=1:viewers.Count
                    viewerH=viewerHValues{i};
                    numAxes=length(get_param(viewerH,'IOSignals'));
                    for axis=1:numAxes


                        okToThrowErr=true;
                        disconnected=Simulink.scopes.ViewerUtil.Disconnect('viewer',viewerH,axis,outport,okToThrowErr);

                        if disconnected
                            disViewers(end+1)=viewerH;%#ok<AGROW>
                            disAxes(end+1)=axis;%#ok<AGROW>
                        end
                    end
                end
            end
        end

        function connectViewers(outport,viewers,vAxes)

            numberOfViewers=length(viewers);
            for i=1:numberOfViewers
                viewerH=viewers(i);
                connected=Simulink.scopes.ViewerUtil.Connect('viewer',viewerH,vAxes(i),outport,true);
                assert(connected);
            end
        end
    end
end


