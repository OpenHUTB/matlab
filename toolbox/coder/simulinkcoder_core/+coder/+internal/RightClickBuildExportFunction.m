



classdef RightClickBuildExportFunction<coder.internal.RightClickBuild
    methods(Access=public)
        function this=RightClickBuildExportFunction(mdlH,blkH,varargin)
            this@coder.internal.RightClickBuild(mdlH,blkH,varargin{:});
        end

        function needConvertSys=runChecks(this)
            this.checkInsidePeriodicFCSS(this.Systems);
            needConvertSys=this.checkExportFcnsCondition(this.Systems);
        end





        function needConvertSys=checkExportFcnsCondition(thisHdl,ssBlkH)
            thisHdl.mdlFcnCallInps=getCompiledFunctionCallInports(ssBlkH);
            thisHdl.mdlExpFcnCallSS=ssBlkH;


            if strcmp(coder.internal.RightClickBuildExportFunction.checkTrigSSTypeUsingTrigPortBlock(ssBlkH),'function-call')
                thisHdl.mdlExpFcnCallSS=ssBlkH;


                blkTrigPortH=get_param(ssBlkH,'PortHandles');
                blkTrigPortIdx=length(blkTrigPortH.Inport)+1;
                blkTrigPortH=blkTrigPortH.Trigger;
                triggerPortWidth=get_param(blkTrigPortH,'CompiledPortWidth');
                if(~isempty(triggerPortWidth)&&(triggerPortWidth>1))
                    msg=message('RTW:buildProcess:invalidWideFcnCallErr',blkTrigPortIdx,getfullname(ssBlkH));
                    ME=MSLException(msg);
                    ME.throw();
                end
                coder.internal.RightClickBuildExportFunction.checkExportFcnsAreDrivenByNonVirtualBus(ssBlkH,thisHdl);
                needConvertSys=false;
                return;
            end




            if~isempty(thisHdl.mdlFcnCallInps.Inports)
                for fIdx=1:length(thisHdl.mdlFcnCallInps.Inports)
                    if thisHdl.mdlFcnCallInps.Inports(fIdx).IsWide==1
                        msg=message('RTW:buildProcess:invalidWideFcnCallErr',thisHdl.mdlFcnCallInps.Inports(fIdx).PortIdx+1,getfullname(ssBlkH));
                        ME=MSLException(msg);
                        ME.throw();
                    end
                end
            end

            if(~isempty(thisHdl.mdlFcnCallInps)&&...
                ~isempty(thisHdl.mdlFcnCallInps.BlocksWhichSpecifyTs))
                errStr='';
                errSep='';
                numBlksSpTs=length(thisHdl.mdlFcnCallInps.BlocksWhichSpecifyTs);
                maxNumErrs=min(5,numBlksSpTs);

                for bIdx=1:maxNumErrs
                    errBlkH=thisHdl.mdlFcnCallInps.BlocksWhichSpecifyTs(bIdx);
                    errStr=sprintf('%s%s''%s''',errStr,errSep,getfullname(errBlkH));
                    errSep=', ';
                end

                autosarTarget=strcmp(get_param(coder.internal.Utilities.localBdroot(ssBlkH),'AutosarCompliant'),'on')==1;
                if autosarTarget
                    DAStudio.error('RTW:buildProcess:invalidTsSpecifiedFcnCallErr',errStr);
                else
                    if numBlksSpTs>1
                        DAStudio.error('RTW:buildProcess:invalidMultipleTsSpecifiedFcnCallErr',errStr);
                    end
                end
            end










            if~isempty(thisHdl.mdlFcnCallInps.Inports)
                if length(thisHdl.mdlFcnCallInps.Inports)>1
                    collectConditionsOnFunctionCallInports=cell(length(thisHdl.mdlFcnCallInps.Inports),1);
                    collectInportNames=cell(length(thisHdl.mdlFcnCallInps.Inports),1);
                    for fIdx=1:length(thisHdl.mdlFcnCallInps.Inports)
                        destBlkH=thisHdl.mdlFcnCallInps.Inports(fIdx).DestBlock;
                        collectConditionsOnFunctionCallInports{fIdx}=get_param(destBlkH,'CompiledLocalCGVCE');
                        collectInportNames{fIdx}=getfullname(destBlkH);
                    end
                    uniqueConditions=unique(collectConditionsOnFunctionCallInports);
                    if length(uniqueConditions)~=1
                        empties=cellfun('isempty',collectConditionsOnFunctionCallInports);
                        collectConditionsOnFunctionCallInports(empties)={'unconditional'};
                        DAStudio.error('Simulink:Variants:ExportFunctionInlineVariantBuildFailure',...
                        getfullname(ssBlkH),...
                        ['''',strjoin(collectInportNames,''','''),''''],...
                        ['''',strjoin(collectConditionsOnFunctionCallInports,''','''),'''']);
                    end
                end
            end



            needConvertSys=thisHdl.localRecCheckExportFcnsContent(ssBlkH);
        end
    end


    methods(Static,Access=public)
        function inlineSubsystemName=setExpFcnSubsystemParameters(fcnCallInps,fcnportIdx,expFcnH,expFcnName)
            inlineSubsystemName='';

            if~(fcnportIdx<=length(fcnCallInps.Inports)&&...
                length(fcnCallInps.Inports(fcnportIdx).DestBlock)==1)
                return;
            end

            blkPortH=fcnCallInps.Inports(fcnportIdx).DestBlock;

            blkType=get_param(blkPortH,'BlockType');

            if~strcmp(blkType,'SubSystem')
                return;
            end


            if strcmp(get_param(blkPortH,'IsSubsystemVirtual'),'on')
                return;
            end



            rtwSystemCode=get_param(blkPortH,'RTWSystemCode');
            if~strcmp(rtwSystemCode,'Nonreusable function')&&~strcmp(rtwSystemCode,'Reusable function')
                return;
            end




            rtwMemSecFuncInitTerm=get_param(blkPortH,'RTWMemSecFuncInitTerm');
            rtwMemSecFuncExecute=get_param(blkPortH,'RTWMemSecFuncExecute');

            set_param(expFcnH,...
            'RTWMemSecFuncInitTerm',rtwMemSecFuncInitTerm,...
            'RTWMemSecFuncExecute',rtwMemSecFuncExecute);








            rtwFcnName=get_param(blkPortH,'RTWFcnName');
            rtwFcnNameOpts=get_param(blkPortH,'RTWFcnNameOpts');
            if strcmp(rtwFcnNameOpts,'Use subsystem name')
                funcName=get_param(blkPortH,'Name');
            elseif strcmp(rtwFcnNameOpts,'User specified')
                funcName=rtwFcnName;
            else

                funcName='';
            end


            if~isempty(funcName)&&strcmp(funcName,expFcnName)
                o=get_param(blkPortH,'Object');
                if strcmp(rtwSystemCode,'Reusable function')

                    MSLDiagnostic('Simulink:Engine:RTWGenNoInliningSubsysOfReusableFunction',...
                    expFcnName,o.getFullName).reportAsWarning;
                elseif strcmp(get_param(blkPortH,'FunctionWithSeparateData'),'on')


                    MSLDiagnostic('Simulink:Engine:RTWGenNoInliningSubsysOfSeparateData',...
                    expFcnName,o.getFullName).reportAsWarning;
                else
                    inlineSubsystemName=o.getFullName;
                end
            end
        end
    end


    methods(Access=protected)

        function[atomicSubsystem,inlineSubsystem,block_name]=...
            changeSubsystemSettings(thisHdl,block_hdl,atomicSubsystem,inlineSubsystem,block_name)%#ok
        end
    end


    methods(Static,Access=protected)
        function convertToAtomicSubsystem(new_blk_hdl,atomicSubsystem,inlineSubsystem)%#ok

        end


        function strPrm=checkFunctionCallPortType(inpH,strPrm)




            if strcmp(get_param(inpH,'PortType'),'trigger')&&...
                strcmp(coder.internal.RightClickBuildExportFunction.checkTrigSSTypeUsingTrigPortBlock(get_param(inpH,'Parent')),'function-call')
                strPrm.CompiledPortDataType='fcn_call';
                strPrm.AliasPortDataType='fcn_call';
            end
            if strcmp(get_param(inpH,'PortType'),'trigger')&&...
                ~strcmp(strPrm.CompiledPortDataType,'fcn_call')
                DAStudio.error('RTW:buildProcess:onlyFcnCallSSErr');
            end
            strPrm.OrigPortH=inpH;
        end
    end


    methods(Access=private)



        function needConvertSys=localRecCheckExportFcnsContent(thisHdl,ssBlkH)
            needConvertSys=false;
            foundFcnCallSys=false;
            foundTrigSys=false;
            autosarTarget=strcmp(get_param(coder.internal.Utilities.localBdroot(ssBlkH),'AutosarCompliant'),'on')==1;

            ssBlkPortHdl=get_param(ssBlkH,'PortHandles');
            if isempty(ssBlkPortHdl.Trigger)&&strcmp(get_param(ssBlkH,'TreatAsAtomicUnit'),'on')
                DAStudio.error('RTW:buildProcess:novirtualSubsystemErr',...
                getfullname(ssBlkH));
            end


            blockList=find_system(ssBlkH,'SearchDepth',1,'LookUnderMasks','all',...
            'FollowLinks','on');
            for i=1:length(blockList)
                blkH=blockList(i);
                if isequal(blkH,ssBlkH)
                    continue;
                end
                blockType=get_param(blkH,'BlockType');
                viewingDevice=strcmp(blockType,'Scope')||strcmp(blockType,'Display');

                blkST=coder.internal.RightClickBuildExportFunction.filterConstantAndParameter(get_param(blkH,'CompiledSampleTime'));

                if strcmp(get_param(blkH,'virtual'),'on')&&...
                    strcmpi(blockType,'Subsystem')
                    needConvertSys=thisHdl.localRecCheckExportFcnsContent(blkH);
                    if needConvertSys
                        DAStudio.error('RTW:buildProcess:trigSysMustBeAtTopToExportCode',...
                        strrep(getfullname(blkH),sprintf('\n'),'\n'))
                    end
                else
                    if strcmpi(blockType,'Subsystem')
                        if(autosarTarget||~isequal(blkST(1),inf))&&...
                            strcmp(get_param(blkH,'SimViewingDevice'),'off')

                            portHs=get_param(blkH,'PortHandles');
                            if isempty(portHs.Trigger)
                                if autosarTarget


                                    DAStudio.error('RTW:autosar:unsupportedAutosarMultirunnableBlkErr',...
                                    getfullname(blkH));
                                elseif~Simulink.SubsystemType(blkH).isSimulinkFunction
                                    DAStudio.error('RTW:buildProcess:unsupportedFcnCallBlkErr',...
                                    getfullname(blkH));
                                end
                            elseif strcmp(get_param(portHs.Trigger,...
                                'CompiledPortAliasedThruDataType'),'fcn_call')
                                foundFcnCallSys=true;
                            else
                                trigSSType=coder.internal.RightClickBuildExportFunction.checkTrigSSTypeUsingTrigPortBlock(blkH);
                                if strcmp(trigSSType,'function-call')&&...
                                    ~isempty(thisHdl.mdlFcnCallInps.Inports)


                                    blkIsConnected=false;
                                    for fIdx=1:length(thisHdl.mdlFcnCallInps.Inports)
                                        if blkH==thisHdl.mdlFcnCallInps.Inports(fIdx).DestBlock
                                            blkIsConnected=true;
                                            break;
                                        end
                                    end
                                    assert(blkIsConnected);
                                    foundFcnCallSys=true;
                                else
                                    if~autosarTarget
                                        if get_param(portHs.Trigger,'CompiledPortWidth')>1
                                            DAStudio.error('RTW:buildProcess:triggerSignalMustBeScalar',...
                                            getfullname(blkH));
                                        end
                                        needConvertSys=true;
                                        foundTrigSys=true;
                                    else
                                        if autosarTarget
                                            DAStudio.error('RTW:autosar:unsupportedFcnCallBlkForAutosarErr',...
                                            getfullname(blkH));
                                        else
                                            DAStudio.error('RTW:buildProcess:unsupportedFcnCallBlkErr',...
                                            getfullname(blkH));
                                        end
                                    end
                                end
                            end
                        end
                    elseif strcmp(blockType,'DataStoreMemory')

                    elseif strcmp(blockType,'Merge')

                    elseif isequal(blkST(1),inf)&&~strcmp(get_param(blkH,'virtual'),'on')&&~autosarTarget


                    elseif strcmp(blockType,'ModelReference')&&~autosarTarget
                        mdlRefPortH=get_param(blkH,'PortHandles');



                        if isempty(mdlRefPortH.Trigger)
                            DAStudio.error('RTW:buildProcess:unsupportedFcnCallBlkErr',...
                            getfullname(blkH));
                        elseif strcmp(get_param(blkH,'TriggerPortTriggerType'),'function-call')
                            if~strcmp(get_param(mdlRefPortH.Trigger,...
                                'CompiledPortDataType'),'fcn_call')

                                blkIsConnected=false;
                                for fIdx=1:length(thisHdl.mdlFcnCallInps.Inports)
                                    if blkH==thisHdl.mdlFcnCallInps.Inports(fIdx).DestBlock
                                        blkIsConnected=true;
                                        break;
                                    end
                                end
                                if~blkIsConnected
                                    DAStudio.error('RTW:buildProcess:unconnectedFcnCallErr',...
                                    getfullname(blkH));
                                end
                            end
                        else

                            DAStudio.error('RTW:buildProcess:unsupportedFcnCallBlkErr',...
                            getfullname(blkH));
                        end
                    elseif autosarTarget
                        if~viewingDevice&&...
                            ~strcmp(blockType,'Goto')&&...
                            ~strcmp(blockType,'From')&&...
                            ~strcmp(blockType,'Inport')&&...
                            ~strcmp(blockType,'InportShadow')&&...
                            (~strcmp(get_param(blkH,'virtual'),'on')||...
                            (~strcmp(blockType,'Outport')&&...
                            ~strcmp(blockType,'SignalSpecification')))
                            DAStudio.error('RTW:autosar:unsupportedAutosarMultirunnableBlkErr',...
                            getfullname(blkH));
                        end
                    else

                        if slfeature('RightClickExportFunctionsWithInlineVariant')>0
                            validVirtualBlockTypes={'Outport','Goto','From','BusCreator','BusSelector',...
                            'Mux','Demux','SignalSpecification','GotoTagVisibility','VariantSource','VariantSink'};
                        else
                            validVirtualBlockTypes={'Outport','Goto','From','BusCreator','BusSelector',...
                            'Mux','Demux','SignalSpecification','GotoTagVisibility'};
                        end
                        validNonVirtualBlockTypes={'Concatenate'};

                        if strcmp(blockType,'DataStoreRead')||...
                            strcmp(blockType,'DataStoreWrite')
                            needConvertSys=true;
                        elseif~viewingDevice&&~any(strcmp(blockType,{'Inport','InportShadow','FunctionCallSplit','FunctionCallFeedbackLatch'}))&&...
                            ~any(strcmp(blockType,validNonVirtualBlockTypes))&&...
                            (~strcmp(get_param(blkH,'virtual'),'on')||~any(strcmp(blockType,validVirtualBlockTypes)))
                            DAStudio.error('RTW:buildProcess:unsupportedFcnCallBlkErr',...
                            getfullname(blkH));
                        end
                    end
                end
            end

            if foundTrigSys&&foundFcnCallSys
                DAStudio.error('RTW:buildProcess:mixTrigWithFcnCallErr',...
                getfullname(ssBlkH));
            end
        end
    end


    methods(Static,Access=private)
        function filteredTs=filterConstantAndParameter(ts)
            if iscell(ts)
                filteredTs={};
                for i=1:numel(ts)
                    if~isequal(ts{i}(1),inf)||...
                        (~isequal(ts{i}(2),inf)&&~isequal(ts{i}(2),0))
                        filteredTs{end+1}=ts{i};%#ok
                    end
                end
                if numel(filteredTs)==1
                    filteredTs=filteredTs{1};
                end
                if numel(filteredTs)==0
                    filteredTs=ts{1};
                end
            else
                filteredTs=ts;
            end
        end




        function ssType=checkTrigSSTypeUsingTrigPortBlock(ssBlkH)
            ssType='Unknown';
            blockList=find_system(ssBlkH,'SearchDepth',1,'LookUnderMasks','all','FollowLinks','on');
            N=length(blockList);
            for i=1:N
                blkH=blockList(i);
                if strcmp(get_param(blkH,'BlockType'),'TriggerPort')
                    ssType=get_param(blkH,'TriggerType');
                    return;
                end
            end
        end

        function checkExportFcnsAreDrivenByNonVirtualBus(ssBlkH,thisHdl)


            if~thisHdl.useCompBusStruct
                return;
            end

            portHandles=get_param(ssBlkH,'PortHandles');
            for i=1:length(portHandles.Inport)
                inportH=portHandles.Inport(i);
                isBus=get_param(inportH,'CompiledBusStruct');
                isStruct=get_param(inportH,'IsCompiledStructureBus');



                if~isempty(isBus)&&isStruct==0
                    blkH=coder.internal.slBus('LocalGetBlockForPortPrm',inportH,'Handle');
                    DAStudio.error('RTW:buildProcess:invalidFcnCallBusErr',getfullname(blkH));
                end
            end

            for i=1:length(portHandles.Outport)
                ph=coder.internal.slBus('LocalGetBlockForPortPrm',portHandles.Outport(i),'PortHandles');
                isBus=get_param(ph.Inport,'CompiledBusStruct');
                isStruct=get_param(ph.Inport,'IsCompiledStructureBus');



                if~isempty(isBus)&&isStruct==0
                    blkH=coder.internal.slBus('LocalGetBlockForPortPrm',portHandles.Outport(i),'Handle');
                    DAStudio.error('RTW:buildProcess:invalidFcnCallBusErr',getfullname(blkH));
                end
            end
        end
    end
end


