classdef ExportFcnValidator<autosar.validation.PhasedValidator




    methods(Access=public)
        function this=ExportFcnValidator(modelHandle)
            this@autosar.validation.PhasedValidator('ModelHandle',modelHandle);
        end
    end

    methods(Access=protected)

        function verifyInitial(this,newSubsysHdl,~)
            this.verifyIOPortsAreConnected(newSubsysHdl);
            this.verifyGraphicalBlocks(newSubsysHdl);
            this.verifyIRVs(newSubsysHdl);
            this.verifyFcnCallInportsSampleTime(newSubsysHdl);
        end

        function verifyPostProp(this,newSubsysHdl,~)

            this.verifyIRVsTopModel(newSubsysHdl);
            this.verifyGotoFromBlocks(newSubsysHdl);
            this.verifyIRVDataTypes(newSubsysHdl);
        end
    end

    methods(Access=private)
        function verifyIRVDataTypes(this,ssBlkH)



            hModel=bdroot(ssBlkH);
            cs=getActiveConfigSet(hModel);
            maxShortNameLength=get_param(cs,'AutosarMaxShortNameLength');

            isSupportMatrixIOAsArray=strcmpi(...
            get_param(cs,'AutosarMatrixIOAsArray'),'on');

            isMultiRunnable=autosar.validation.ExportFcnValidator.isMultiRunnable(ssBlkH);

            if isMultiRunnable
                lines=autosar.validation.ExportFcnValidator.findSystemThruVirtualSubsystems(ssBlkH,'line');
                for idx=1:length(lines)
                    lineObj=get_param(lines(idx),'Object');
                    srcBlock=lineObj.SrcBlockHandle;
                    dstBlocks=lineObj.DstBlockHandle;



                    if srcBlock<0&&(isempty(dstBlocks)||dstBlocks(1)<0)
                        continue;
                    end



                    if slInternal('isFunctionCallSubsystem',srcBlock)||...
                        strcmp(get_param(srcBlock,'BlockType'),'Merge')
                        for dstIdx=1:length(dstBlocks)
                            if slInternal('isFunctionCallSubsystem',dstBlocks(dstIdx))

                                if lineObj.getSourcePort.CompiledPortComplexSignal
                                    msg=message('RTW:autosar:MultiRunnableInterrunnableComplex',...
                                    get_param(lineObj.SrcPortHandle,'PortNumber'),...
                                    autosar.validation.AutosarUtils.removeNewLine(getfullname(srcBlock)));
                                    ME=MSLException(msg);
                                    ME.throw();
                                end

                                if strcmp(lineObj.getSourcePort.CompiledBusType,'VIRTUAL_BUS')
                                    msg=message('autosarstandard:validation:MultiRunnableInterrunnableVirtualBus',...
                                    get_param(lineObj.SrcPortHandle,'PortNumber'),...
                                    autosar.validation.AutosarUtils.removeNewLine(getfullname(srcBlock)));
                                    ME=MSLException(msg);
                                    ME.throw();
                                end


                                this.AutosarUtilsValidator.checkDataType(lineObj.getFullName,...
                                get_param(lineObj.SrcPortHandle,...
                                'CompiledPortDataType'),...
                                maxShortNameLength,isSupportMatrixIOAsArray);

                                if~strcmp(lineObj.getSourcePort.CompiledRTWStorageClass,'Auto')
                                    msg=message('RTW:autosar:MultiRunnableInterrunnableNonAutoStorageClass',...
                                    lineObj.Name,...
                                    get_param(lineObj.SrcPortHandle,'PortNumber'),...
                                    autosar.validation.AutosarUtils.removeNewLine(getfullname(srcBlock)));
                                    ME=MSLException(msg);
                                    ME.throw();
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    methods(Static,Access=public)

        function isExportFcn=isExportFcn(hModel)
            isExportFcn=autosar.validation.ExportFcnValidator.isTopModelExportFcn(hModel);
        end

        function isServerSS=isServerSubSys(sys)
            if Simulink.CodeMapping.isAutosarAdaptiveSTF(bdroot(sys))

                isServerSS=autosar.validation.ExportFcnValidator.isPublicScopedSimulinkFunction(sys)...
                ||autosar.validation.ExportFcnValidator.isPortScopedSimulinkFunction(sys);
            else
                isServerSS=autosar.utils.SimulinkFunction.isGlobalSimulinkFunction(sys);
            end
        end

        function isScoped=isScopedSimulinkFunction(sys)
            isScoped=false;
            if(strcmp(get_param(sys,'BlockType'),'SubSystem')&&...
                strcmp(get_param(sys,'IsSimulinkFunction'),'on'))
                trigPort=find_system(sys,'SearchDepth',1,...
                'FollowLinks','on','BlockType','TriggerPort');
                if strcmp(get_param(trigPort,'FunctionVisibility'),'scoped')
                    isScoped=true;
                end
            end
        end

        function isPortScoped=isPortScopedSimulinkFunction(sys)
            isPortScoped=false;
            if(strcmp(get_param(sys,'BlockType'),'SubSystem')&&...
                strcmp(get_param(sys,'IsSimulinkFunction'),'on'))
                trigPort=find_system(sys,'SearchDepth',1,...
                'FollowLinks','on','BlockType','TriggerPort');
                if strcmp(get_param(trigPort,'FunctionVisibility'),'port')
                    isPortScoped=true;
                end
            end
        end

        function isPublicScoped=isPublicScopedSimulinkFunction(sys)


            isScoped=autosar.validation.ExportFcnValidator.isScopedSimulinkFunction(sys);
            isAtRoot=strcmp(get_param(sys,'Parent'),get_param(bdroot(sys),'Name'));
            isPublicScoped=isScoped&&isAtRoot;
        end

        function[isAsyncFcnCall,rootFcnCallInportName]=isTopModelAsyncFcnCall(sys)


            isAsyncFcnCall=false;
            rootFcnCallInportName=[];
            isExportFcn=slprivate('getIsExportFcnModel',bdroot(sys));
            if(~isExportFcn)
                rootFcnCallInport=find_system(bdroot(sys),'SearchDepth',1,...
                'FollowLinks','on','blocktype','Inport',...
                'OutputFunctionCall','on');
                if~isempty(rootFcnCallInport)
                    rootFcnCallInportName=rootFcnCallInport{1};
                    isAsyncFcnCall=true;
                end
            end
        end

        function isExportFcn=isTopModelExportFcn(sys)
            isExportFcn=slprivate('getIsExportFcnModel',bdroot(sys));
            if~isExportFcn

                slServers=find_system(bdroot(sys),'SearchDepth',1,...
                'FollowLinks','on','blocktype','SubSystem',...
                'IsSimulinkFunction','on');
                if~isempty(slServers)
                    isExportFcn=true;
                end
            end
        end

        function isModelWideEvent=isModelWideEvent(blkH)



            isModelWideEvent=false;
            if~strcmp(get_param(blkH,'BlockType'),'SubSystem')
                return
            end
            blockList=find_system(blkH,'SearchDepth',1,'LookUnderMasks','all',...
            'FollowLinks','on');
            for ii=1:length(blockList)
                blkH=blockList(ii);
                if strcmp(get_param(blkH,'BlockType'),'EventListener')&&...
                    ismember(get_param(blkH,'EventType'),...
                    {'Initialize','Reset','Terminate'})
                    isModelWideEvent=true;
                    return
                end
            end
        end

    end



    methods(Static,Access=private)

        function verifyIRVs(ssBlkH)



            isMultiRunnable=autosar.validation.ExportFcnValidator.isMultiRunnable(ssBlkH);
            isExportFcn=autosar.validation.ExportFcnValidator.isExportFcn(ssBlkH);



            if isMultiRunnable&&isExportFcn
                [status,msg]=autosar.validation.p_checkIrvs(ssBlkH,ssBlkH,true);
                if status==0
                    autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
                end
            end
        end
        function verifyFcnCallInportsSampleTime(ssBlkH)
            if(autosar.validation.ExportFcnValidator.isTopModelExportFcn(ssBlkH))
                mdlName=bdroot(ssBlkH);
                mapping=autosar.api.Utils.modelMapping(mdlName);
                for ii=1:numel(mapping.FcnCallInports)
                    blk=mapping.FcnCallInports(ii).Block;
                    runnableName=mapping.FcnCallInports(ii).MappedTo.Runnable;
                    if~isempty(runnableName)
                        m3iRunnable=autosar.validation.ClientServerValidator.findM3iRunnableFromName(mdlName,runnableName);
                        runnableHasTimingEvent=autosar.validation.ExportFcnValidator.hasTimingEvent(m3iRunnable);

                        sample_time_expr=get_param(blk,'SampleTime');
                        [sampleTime,itExists]=slResolve(sample_time_expr,blk);
                        if runnableHasTimingEvent
                            if itExists
                                if sampleTime(1)<0
                                    messageID='RTW:autosar:errorInvalidParameter';
                                    autosar.validation.Validator.logError(messageID,runnableName,...
                                    'Sample time',mapping.FcnCallInports(ii).Block,...
                                    'value greater than zero');
                                end
                                if(length(sampleTime)>1&&sampleTime(2)>0)
                                    messageID='RTW:autosar:errorInvalidParameter';
                                    autosar.validation.Validator.logError(messageID,runnableName,...
                                    'Sample time',mapping.FcnCallInports(ii).Block,...
                                    'zero initial time offset');
                                end
                            end

                        else
                            if itExists&&sampleTime(1)~=-1
                                messageID='RTW:autosar:errorPeriodicFunctionWithoutTimingEvent';
                                autosar.validation.Validator.logError(messageID,runnableName,...
                                mapping.FcnCallInports(ii).Block);
                            end
                        end
                    end
                end
            end
        end

        function verifyIRVsTopModel(ssBlkH)





            lines=find_system(ssBlkH,'FindAll','on','SearchDepth',...
            1,'FollowLinks','on','LookUnderMasks','all',...
            'Type','line');
            for idx=1:length(lines)
                lineObj=get_param(lines(idx),'Object');
                lineName=get_param(lineObj.Handle,'Name');
                if~isempty(lineName)
                    if any(lineName>=128)
                        autosar.validation.Validator.logError('autosarstandard:validation:nonAsciiSignal',...
                        lineName);
                    end
                end
                srcBlock=lineObj.SrcBlockHandle;
                dstBlocks=lineObj.DstBlockHandle;

                if srcBlock<0
                    if~isempty(dstBlocks)&&dstBlocks(1)>0







                        msg=message('RTW:autosar:MultiRunnableLineWithNoSrc',...
                        get_param(lineObj.DstPortHandle,'PortNumber'),...
                        autosar.validation.AutosarUtils.removeNewLine(getfullname(dstBlocks(1))));
                        ME=MSLException(msg);
                        ME.throw();

                    else

                        continue
                    end
                end


                if isempty(dstBlocks)||dstBlocks(1)<0
                    msg=message('RTW:autosar:MultiRunnableLineWithNoDst',...
                    get_param(lineObj.SrcPortHandle,'PortNumber'),...
                    autosar.validation.AutosarUtils.removeNewLine(getfullname(srcBlock)));
                    ME=MSLException(msg);
                    ME.throw();
                end
            end


            if(autosar.validation.ExportFcnValidator.isTopModelExportFcn(ssBlkH))
                mapping=autosar.api.Utils.modelMapping(bdroot(ssBlkH));
                mapping.validateDataTransfers();
            end
        end


        function verifyGraphicalBlocks(ssBlkH)



            isMultiRunnable=autosar.validation.ExportFcnValidator.isMultiRunnable(ssBlkH);


            if isMultiRunnable
                blks=autosar.validation.ExportFcnValidator.findSystemThruVirtualSubsystems(ssBlkH,'block');
            else
                blks=ssBlkH;
            end

            hModel=bdroot(ssBlkH);
            for idx=1:length(blks)



                if strcmp(get_param(blks(idx),'BlockType'),'From')
                    blkObj=get_param(blks(idx),'Object');
                    if isempty(blkObj.GotoBlock.handle)
                        autosar.validation.Validator.logError('RTW:autosar:MultiRunnableLineWithNoGoto',...
                        autosar.validation.AutosarUtils.removeNewLine(getfullname(blks(idx))));
                    end





                elseif strcmp(get_param(blks(idx),'BlockType'),'Goto')
                    if~autosar.validation.ExportFcnValidator.isTopModelExportFcn(hModel)&&...
                        ~strcmp(get_param(blks(idx),'TagVisibility'),'local')
                        autosar.validation.Validator.logError('RTW:autosar:NonLocalGotoInWrapper',...
                        autosar.validation.AutosarUtils.removeNewLine(getfullname(blks(idx))));
                    end
                    blkObj=get_param(blks(idx),'Object');
                    fromHandles={blkObj.FromBlocks.handle};
                    if isempty(fromHandles)
                        autosar.validation.Validator.logError('RTW:autosar:MultiRunnableLineWithNoFrom',...
                        autosar.validation.AutosarUtils.removeNewLine(getfullname(blks(idx))));
                    end
                end
            end

        end

        function verifyIOPortsAreConnected(ssBlkH)



            isMultiRunnable=autosar.validation.ExportFcnValidator.isMultiRunnable(ssBlkH);
            if isMultiRunnable
                ports=autosar.validation.ExportFcnValidator.findSystemThruVirtualSubsystems(ssBlkH,'port');
                for idx=1:length(ports)
                    portObj=get_param(ports(idx),'Object');
                    parent=portObj.Parent;
                    if get_param(parent,'Handle')~=ssBlkH
                        lineH=portObj.Line;
                        isError=false;


                        if lineH<0
                            if~(autosar.validation.ExportFcnValidator.isServerSubSys(parent)&&...
                                strcmp(portObj.PortType,'trigger'))&&...
                                ~autosar.simulink.functionPorts.Utils.isClientServerPort(parent)
                                isAtRoot=strcmp(get_param(parent,'Parent'),bdroot(parent));
                                if autosar.validation.ExportFcnValidator.isScopedSimulinkFunction(parent)
                                    if isAtRoot

                                        autosar.validation.Validator.logError('RTW:autosar:ModelLevelScopedSimulinkFunction',parent);
                                    else


                                        continue;
                                    end
                                end
                                isError=true;
                            end
                        else
                            allBlkH=cat(1,get_param(lineH,'SrcBlockHandle'),...
                            get_param(lineH,'DstBlockHandle'));
                            for blkIdx=1:length(allBlkH)
                                blkH=allBlkH(blkIdx);
                                if(blkH>=0&&...
                                    strcmp(get_param(blkH,'Commented'),'on'))
                                    isError=true;
                                end
                            end
                        end
                        if isError
                            portType=portObj.PortType;
                            portType(1)=upper(portType(1));
                            autosar.validation.Validator.logError('RTW:autosar:MultiRunnableUnconnectedPort',...
                            portType,...
                            portObj.PortNumber,...
                            autosar.validation.AutosarUtils.removeNewLine(getfullname(parent)));
                        end
                    end
                end
            end

        end

        function verifyGotoFromBlocks(ssBlkH)

            isMultiRunnable=autosar.validation.ExportFcnValidator.isMultiRunnable(ssBlkH);
            if isMultiRunnable
                runnablesHdls=autosar.validation.ExportFcnValidator.getRunnableHdls(ssBlkH,isMultiRunnable);
                fromBlocks=find_system(ssBlkH,'LookUnderMasks','all',...
                'MatchFilter',@Simulink.match.activeVariants,...
                'FollowLinks','on','BlockType','From');

                for idx=1:length(fromBlocks)
                    fromBlock=fromBlocks(idx);
                    gotoBlock=get_param(fromBlock,'GotoBlock');
                    gotoBlock=gotoBlock.handle;
                    if~isempty(gotoBlock)
                        fromRunnable=autosar.validation.ExportFcnValidator.findRunnableOwner(fromBlock,runnablesHdls);
                        gotoRunnable=autosar.validation.ExportFcnValidator.findRunnableOwner(gotoBlock,runnablesHdls);
                        if~isequal(fromRunnable,gotoRunnable)
                            autosar.validation.Validator.logError(...
                            'RTW:autosar:InvInterSysConnAutosarRunnable',...
                            autosar.validation.AutosarUtils.removeNewLine(getfullname(gotoRunnable)),...
                            autosar.validation.AutosarUtils.removeNewLine(getfullname(gotoBlock)),...
                            autosar.validation.AutosarUtils.removeNewLine(getfullname(fromBlock)));
                        end
                    end
                end
            end


        end

    end

    methods(Static,Access=public)

        function runnablesHdls=getRunnableHdls(ssBlkH,isMultiRunnable)

            runnablesHdls=[];
            if isMultiRunnable
                blks=autosar.validation.ExportFcnValidator.findSystemThruVirtualSubsystems(...
                ssBlkH,'block');
                for idx=1:length(blks)
                    if strcmpi(get_param(blks(idx),'BlockType'),'SubSystem')&&...
                        slInternal('isFunctionCallSubsystem',blks(idx))
                        runnablesHdls(end+1)=blks(idx);%#ok<AGROW>
                    end
                end
            end
        end

        function runnable=findRunnableOwner(block,runnablesHdls)
            parent=get_param(get_param(block,'Parent'),'Handle');
            parentType=get_param(parent,'Type');
            if~strcmpi(parentType,'block')
                runnable=[];
            elseif~isempty(find(runnablesHdls==parent,1))
                runnable=parent;
            else
                runnable=autosar.validation.ExportFcnValidator.findRunnableOwner(parent,runnablesHdls);
            end
        end

    end

    methods(Static,Access=private)

        function objs=findSystemThruVirtualSubsystems(ctxt,searchType)
            objs=[];
            blockList=find_system(ctxt,'SearchDepth',...
            1,'LookUnderMasks','all','FollowLinks','on');
            for i=1:length(blockList)
                ssBlkH=blockList(i);
                if~isequal(ssBlkH,ctxt)&&strcmp(get_param(ssBlkH,'BlockType'),'SubSystem')
                    if strcmpi(get_param(ssBlkH,'Virtual'),'on')
                        ssObjs=autosar.validation.ExportFcnValidator.findSystemThruVirtualSubsystems(ssBlkH,searchType);
                        objs=[objs;ssObjs];%#ok
                    end
                end
            end
            localObjs=find_system(ctxt,...
            'FindAll','on',...
            'SearchDepth',1,...
            'LookUnderMasks','all',...
            'FollowLinks','on',...
            'Type',searchType);
            objs=[objs;localObjs];
        end


        function checkForEnabledSubsystemsWithResetConditions(sys,isMultiRunnable)


            if~isMultiRunnable
                return
            end




            subsystemBlks=find_system(sys,'LookUnderMasks','all',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'FollowLinks','on','BlockType','SubSystem');

            for idx=1:length(subsystemBlks)

                enablePortBlks=find_system(subsystemBlks(idx),'SearchDepth',1,'LookUnderMasks','all',...
                'FollowLinks','on','BlockType','EnablePort');

                if isempty(enablePortBlks)

                    continue
                end




                StatesWhenEnabledResetPortList=find_system(subsystemBlks(idx),'SearchDepth',1,'LookUnderMasks','all',...
                'FollowLinks','on','BlockType','EnablePort',...
                'StatesWhenEnabling','reset');

                if~isempty(StatesWhenEnabledResetPortList)
                    autosar.validation.Validator.logError('RTW:autosar:multirunnableHasStatesWhenEnabledReset',...
                    autosar.validation.AutosarUtils.removeNewLine(getfullname(StatesWhenEnabledResetPortList(1))));
                end

                outblks=find_system(subsystemBlks(idx),'FindAll','on','SearchDepth',1,'BlockType','Outport');
                for idx2=1:length(outblks)




                    if strcmp(get_param(outblks(idx2),'OutputWhenDisabled'),'reset')
                        autosar.validation.Validator.logError('RTW:autosar:multirunnableHasOutputWhenDisabledReset',...
                        autosar.validation.AutosarUtils.removeNewLine(getfullname(outblks(idx2))));
                    end
                end
            end
        end

        function isMultiRunnable=isMultiRunnable(blkH)

            switch get_param(blkH,'Type')
            case 'block_diagram'
                isMultiRunnable=true;
            otherwise
                isMultiRunnable=~slInternal('isFunctionCallSubsystem',blkH);
            end
        end

        function hasTimingEvent=hasTimingEvent(m3iRunnable)

            hasTimingEvent=any(m3i.map(@(m3iEvent)isa(m3iEvent,'Simulink.metamodel.arplatform.behavior.TimingEvent'),m3iRunnable.Events));
        end

    end

end




