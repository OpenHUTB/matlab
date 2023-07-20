




classdef RightClickBuild<handle
    properties(SetAccess=public,GetAccess=public)
Model
Systems

exportFcns
ss2mdlForSLDV
ss2mdlForPLC
configureAutosar
autosarMultiRunnable

pushNags

mdlName
mdlHdl

expFcnFileName
expFcnInitFcnName

insidePeriodicFCSS
compiledSampleTime
bUseGlobalSampleTime
        useCompBusStruct=false

mdlExpFcnCallSS
mdlFcnCallInps
wstate
        numFcnCalls=0
actualDataTypeOverride
    end


    properties(SetAccess=private,GetAccess=public)
NewModel
StrPorts
Exception
    end


    methods(Static,Access=public)
        function this=create(mdlH,blkH,varargin)
            params=coder.internal.RightClickBuild.parse(varargin{:});

            if~params.SS2mdlForSLDV&&~params.SS2mdlForPLC&&(strcmp(get_param(mdlH,'AutosarCompliant'),'on')==1)
                DAStudio.error('RTW:autosar:obsoleteSSAsASWC');
            end
            if params.ExportFunctions
                this=coder.internal.RightClickBuildExportFunction(mdlH,blkH,params);
            else
                this=coder.internal.RightClickBuild(mdlH,blkH,params);
            end
        end


        function result=isValidLogicalArg(val)
            result=islogical(val)||isnumeric(val);
        end


        function params=parse(varargin)
            p=inputParser;

            addOptional(p,'ConfigureAutosar',false,@coder.internal.RightClickBuild.isValidLogicalArg);
            addOptional(p,'ExportFunctions',false,@coder.internal.RightClickBuild.isValidLogicalArg);
            addOptional(p,'PushNags',true,@coder.internal.RightClickBuild.isValidLogicalArg);
            addOptional(p,'SS2mdlForSLDV',false,@islogical);
            addOptional(p,'SS2mdlForPLC',false,@islogical);
            addOptional(p,'AutosarMultiRunnable',false,@coder.internal.RightClickBuild.isValidLogicalArg);
            addOptional(p,'ExpFcnFileName','',@ischar);
            addOptional(p,'ExpFcnInitFcnName','',@ischar);
            addOptional(p,'ReplaceSubsystem',false,@coder.internal.RightClickBuild.isValidLogicalArg);
            addOptional(p,'CheckSimulationResults',false,@coder.internal.RightClickBuild.isValidLogicalArg);
            if slfeature('RightClickBuild')==1
                addOptional(p,'ExpandVirtualBusPorts',false,@coder.internal.RightClickBuild.isValidLogicalArg);
            else
                addOptional(p,'ExpandVirtualBusPorts',true,@coder.internal.RightClickBuild.isValidLogicalArg);
            end
            addOptional(p,'GenerateSFunction',false,@islogical);

            parse(p,varargin{:});
            params=p.Results;


            params.ConfigureAutosar=params.ConfigureAutosar>0;
            params.ExportFunctions=params.ExportFunctions>0;
            params.AutosarMultiRunnable=params.AutosarMultiRunnable>0;
            if isfield(params,'ExpandVirtualBusPorts')&&params.ExpandVirtualBusPorts==0
                params.ExpandVirtualBusPorts=false;
            end
            if isfield(params,'ReplaceSubsystem')&&params.ReplaceSubsystem==0
                params.ReplaceSubsystem=false;
            end
            if isfield(params,'CheckSimulationResults')&&params.CheckSimulationResults==0
                params.CheckSimulationResults=false;
            end


            params.ExportFunctions=params.ExportFunctions||params.AutosarMultiRunnable;
        end

    end


    methods(Access=protected)
        function this=RightClickBuild(mdlH,blkH,params)
            this.Model=mdlH;
            this.Systems=blkH;
            this.mdlName=get_param(this.Model,'Name');
            this.mdlHdl=get_param(this.Model,'Handle');


            this.exportFcns=params.ExportFunctions;
            this.configureAutosar=params.ConfigureAutosar;
            this.ss2mdlForSLDV=params.SS2mdlForSLDV;
            this.ss2mdlForPLC=params.SS2mdlForPLC;
            this.autosarMultiRunnable=params.AutosarMultiRunnable;
            this.expFcnFileName=params.ExpFcnFileName;
            this.expFcnInitFcnName=params.ExpFcnInitFcnName;
            this.pushNags=params.PushNags;

            this.wstate=warning('backtrace');
        end


        function[atomicSubsystem,inlineSubsystem,block_name]=...
            changeSubsystemSettings(thisHdl,block_hdl,atomicSubsystem,inlineSubsystem,block_name)












            if(strcmp(get_param(block_hdl,'IsSubsystemVirtual'),'off'))
                atomicSubsystem='on';
                if(strcmp(get_param(block_hdl,'RTWSystemCode'),'Inline')||...
                    strcmp(get_param(block_hdl,'RTWSystemCode'),'Auto'))
                    inlineSubsystem=isequal(get_param(block_hdl,'Variant'),'off');
                elseif(strcmp(get_param(block_hdl,'RTWSystemCode'),'Nonreusable function'))
                    if(strcmp(get_param(block_hdl,'RTWFcnNameOpts'),'Auto')||...
                        strcmp(get_param(block_hdl,'RTWFcnNameOpts'),'Use subsystem name')||...
                        thisHdl.ss2mdlForSLDV||thisHdl.ss2mdlForPLC)
                        functionName=block_name;
                    else
                        functionName=get_param(block_hdl,'RTWFcnName');
                    end
                    if(strcmp(get_param(block_hdl,'RTWFileNameOpts'),'Use subsystem name')||...
                        thisHdl.ss2mdlForSLDV||thisHdl.ss2mdlForPLC)
                        fileName=block_name;
                    elseif(strcmp(get_param(block_hdl,'RTWFileNameOpts'),'Auto')||...
                        strcmp(get_param(block_hdl,'RTWFileNameOpts'),'Use function name'))
                        fileName=functionName;
                    else
                        fileName=get_param(block_hdl,'RTWFileName');
                    end
                    if~isempty(functionName)&&~all(isspace(functionName))&&...
                        strcmp(functionName,fileName)
                        block_name=functionName;
                        inlineSubsystem=isequal(get_param(block_hdl,'Variant'),'off');
                    end
                end
            end
        end
    end


    methods(Static,Access=protected)
        function convertToAtomicSubsystem(new_blk_hdl,atomicSubsystem,inlineSubsystem)
            set_param(new_blk_hdl,'TreatAsAtomicUnit',atomicSubsystem);
            if inlineSubsystem
                set_param(new_blk_hdl,'RTWSystemCode','Inline');
            end
        end


        function strPrm=checkFunctionCallPortType(inpH,strPrm)%#ok
        end
    end


    methods(Access=public)
        function delete(this)
            warning(this.wstate.state,'backtrace');
        end


        function needConvertSys=runChecks(this)
            this.checkInsidePeriodicFCSS(this.Systems);
            needConvertSys=false;
        end

        function[mdl_hdl,new_blk_hdl,error_occ,mExc]=LocalCopySubSystemIntoNewModel(thisHdl,block_hdl)
            error_occ=0;
            mExc=[];
            origMdlName=get_param(bdroot(block_hdl),'Name');
            block_name=get_param(block_hdl,'Name');
            atomicSubsystem='off';
            inlineSubsystem=false;

            [atomicSubsystem,inlineSubsystem,block_name]=...
            thisHdl.changeSubsystemSettings(block_hdl,atomicSubsystem,inlineSubsystem,block_name);





            origBlockName=block_name;


            maxIdLength=get_param(bdroot(block_hdl),'MaxIdLength');

            [base_name,fileName]=coder.internal.convertBlkName2ModelName(block_name,maxIdLength);

            mdl_created=0;
            num_iter=0;

            need_name_change=coder.internal.Utilities.locNeedNameChange(base_name,block_hdl,origMdlName);

            if need_name_change
                mdl_name=sprintf('%s%d',base_name,num_iter);
                while((num_iter<1024)&&...
                    coder.internal.Utilities.locNeedNameChange(mdl_name,block_hdl,origMdlName))
                    num_iter=num_iter+1;
                    mdl_name=sprintf('%s%d',base_name,num_iter);
                end
                base_name=mdl_name;
            else
                mdl_name=base_name;
            end





            shadowWarning='Simulink:Engine:MdlFileShadowing';
            prevWarning1=warning('query',shadowWarning);
            warning('off',shadowWarning);
            caseSensitiveWarning='sl_utility:caseSensitiveBlockDiagramNames:PathWarn';
            prevWarning2=warning('query',caseSensitiveWarning);
            warning('off',caseSensitiveWarning);

            try
                close_system(mdl_name,0);
                new_system(mdl_name,'model');
                mdl_created=1;
            catch exc %#ok<NASGU>
            end


            while(~mdl_created&&num_iter<1024)
                num_iter=num_iter+1;
                mdl_name=sprintf('%s%d',base_name,num_iter);
                try
                    new_system(mdl_name,'model');
                    mdl_created=1;
                catch exc %#ok<NASGU>
                end
            end

            warning(prevWarning1.state,shadowWarning);
            warning(prevWarning2.state,caseSensitiveWarning);

            if~mdl_created
                mExc=coder.internal.ss2mdlErrorExit(origMdlName,-1,'CreateNewModel',[],thisHdl);
                error_occ=1;
                return;
            end

            mdl_hdl=get_param(mdl_name,'Handle');
            set_param(mdl_hdl,'IsTempModelForRightClickBuild','on');
            origBlkHdl=block_hdl;
            while(get_param(bdroot(origBlkHdl),'SubsystemHdlForRightClickBuild')>0)
                origBlkHdl=get_param(bdroot(origBlkHdl),'SubsystemHdlForRightClickBuild');
            end
            set_param(mdl_hdl,'SubsystemHdlForRightClickBuild',origBlkHdl);


            set_param(mdl_hdl,'SIDAllowCopied','on');
            set_param(mdl_hdl,'SIDNewHighWatermark',...
            get_param(bdroot(block_hdl),'SIDHighWatermark'));





            try
                copyReq=get_param(0,'CopyBlkRequirement');
                set_param(0,'CopyBlkRequirement','on');
                new_block_name=[mdl_name,'/',strrep(origBlockName,'/','//')];
                new_blk_hdl=add_block(block_hdl,new_block_name);


                set_param(new_blk_hdl,'Tag',get_param(bdroot(block_hdl),'Name'));
                set_param(mdl_hdl,'NewSubsystemHdlForRightClickBuild',new_blk_hdl);


                slInternal('convertAllSSRefBlocksToSubsystemBlocks',mdl_hdl);
            catch exc
                set_param(0,'CopyBlkRequirement',copyReq);
                mExc=coder.internal.ss2mdlErrorExit(origMdlName,mdl_hdl,'AddBlockToNewModel',...
                exc,thisHdl);
                error_occ=1;
                return;
            end
            set_param(0,'CopyBlkRequirement',copyReq);


            set_param(mdl_hdl,'SIDAllowCopied','off');

            if strcmp(fileName,mdl_name)


                linkstat=get_param(new_blk_hdl,'LinkStatus');
                if isequal(linkstat,'resolved')
                    set_param(new_blk_hdl,'LinkStatus','inactive');
                end
                thisHdl.convertToAtomicSubsystem(new_blk_hdl,atomicSubsystem,inlineSubsystem);
            end

            set_param(new_blk_hdl,'Orientation','right');


            if thisHdl.configureAutosar&&~thisHdl.autosarMultiRunnable&&...
                ~thisHdl.ss2mdlForSLDV&&~thisHdl.ss2mdlForPLC
                try
                    sobj=Simulink.ModelReference.Conversion.ConversionChecks.getConversionCheckObject(block_hdl);%#ok
                    cmdStr='isConvertible = sobj.checkForError()';
                    checklog=evalc(cmdStr);
                    if~isConvertible
                        mExc=coder.internal.ss2mdlErrorExit(origMdlName,mdl_hdl,...
                        'ssNotConvertibleToMdlref',...
                        [],thisHdl,checklog);
                        error_occ=1;return;
                    end
                catch er
                    mExc=coder.internal.ss2mdlErrorExit(origMdlName,mdl_hdl,...
                    'ssNotConvertibleToMdlref',...
                    er,thisHdl,er.message);
                    error_occ=1;return;
                end
            end


            if rtwprivate('isCPPClassGenEnabled',getActiveConfigSet(origMdlName))&&...
                strcmpi(get_param(getActiveConfigSet(origMdlName),'IsCPPClassGenMode'),'on')&&...
                ~thisHdl.ss2mdlForSLDV&&~thisHdl.ss2mdlForPLC
                try
                    sobj=Simulink.ModelReference.Conversion.ConversionChecks.getConversionCheckObject(block_hdl);%#ok
                    cmdStr='isConvertible = sobj.checkForError()';
                    checklog=evalc(cmdStr);
                    if~isConvertible
                        mExc=coder.internal.ss2mdlErrorExit(origMdlName,mdl_hdl,...
                        'ssNotConvertibleToMdlrefCPP',...
                        [],thisHdl,checklog);
                        error_occ=1;return;
                    end
                catch cpper
                    mExc=coder.internal.ss2mdlErrorExit(origMdlName,mdl_hdl,...
                    'ssNotConvertibleToMdlrefCPP',...
                    cpper,thisHdl,cpper.message);
                    error_occ=1;return;
                end
            end
        end


        function[mdl_hdl,error_occ,mExc,machineId]=LocalCopyParams(thisHdl,new_blk_hdl,...
            block_hdl,cs,mdl_hdl,origMdlHdl,...
            hasStateflow,error_occ,mExc,...
            machineId)








            isPolySpaceCommentOn=get_param(bdroot(block_hdl),'InsertPolySpaceComments');
            if(isPolySpaceCommentOn)
                srcRoot=bdroot(block_hdl);
                blkList=get_param(srcRoot,'GetPolySpaceStartCommentBlocks');

                for index=1:length(blkList)
                    if(coder.internal.isBlockInSS(block_hdl,blkList(index)))
                        origSID=Simulink.ID.getSID(blkList(index));
                        newSID=Simulink.ID.getSubsystemBuildSID(origSID,new_blk_hdl);
                        newHandle=Simulink.ID.getHandle(newSID);
                        origPSComment=get_param(blkList(index),'PolySpaceStartComment');
                        set_param(newHandle,'PolySpaceStartComment',origPSComment);
                    end
                end

                blkList=get_param(bdroot(block_hdl),'GetPolySpaceEndCommentBlocks');

                for index=1:length(blkList)
                    if(coder.internal.isBlockInSS(block_hdl,blkList(index)))
                        origSID=Simulink.ID.getSID(blkList(index));
                        newSID=Simulink.ID.getSubsystemBuildSID(origSID,new_blk_hdl);
                        newHandle=Simulink.ID.getHandle(newSID);
                        origPSComment=get_param(blkList(index),'PolySpaceEndComment');
                        set_param(newHandle,'PolySpaceEndComment',origPSComment);
                    end
                end
            end




            autosarCompliant=strcmp(get_param(cs,'AutosarCompliant'),'on')==1;
            if autosarCompliant


                ssType=Simulink.SubsystemType(block_hdl);
                subsystemIsVirtual=ssType.isVirtualSubsystem();
                exportFunctions=thisHdl.exportFcns;
                if subsystemIsVirtual&&~exportFunctions
                    DAStudio.error('RTW:autosar:virtualSubsystemNeedsExportFunctionsCall',getfullname(block_hdl));
                end
            end

            configFlag=(autosarCompliant&&thisHdl.exportFcns)||coder.internal.needFunctionControl(block_hdl,mdl_hdl);
            if configFlag
                fcnprotoConf=get_param(block_hdl,'SSRTWFcnClass');
                if~isempty(fcnprotoConf)
                    if isa(fcnprotoConf,'RTW.ModelSpecificCPrototype')&&...
                        get_param(origMdlHdl,'versionloaded')<=7.1
                        if isempty(fcnprotoConf.InitFunctionName)
                            fcnprotoConf.InitFunctionName=[get_param(mdl_hdl,'name'),'_initialize'];
                        end
                    end
                    set_param(mdl_hdl,'RTWFcnClass',fcnprotoConf);
                end
            end
            if autosarCompliant&&thisHdl.exportFcns
                ssType=Simulink.SubsystemType(block_hdl);
                if ssType.isVirtualSubsystem()
                    blockList=RTW.findRunnables(block_hdl);
                    set_param(new_blk_hdl,'LinkStatus','inactive');
                else
                    blockList=block_hdl;
                end
                for i=1:length(blockList)
                    oldBlkH=blockList(i);

                    if strcmp(get_param(oldBlkH,'RTWSystemCode'),'Reusable function')
                        mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,mdl_hdl,...
                        'NoReusableTopFCSS',[],thisHdl,oldBlkH);
                        error_occ=1;
                        return;
                    end
                end
            end




            if rtwprivate('isCPPClassGenEnabled',cs)&&strcmpi(get_param(cs,'IsCPPClassGenMode'),'on')






                if isempty(Simulink.CodeMapping.getCurrentMapping(origMdlHdl))
                    interfaceConf=get_param(block_hdl,'SSRTWCPPFcnClass');
                    if isempty(interfaceConf)
                        interfaceConf=RTW.ModelCPPDefaultClass('',mdl_hdl);
                    end
                else
                    interfaceConf=RTW.ModelCPPDefaultClass('',mdl_hdl);
                end
                set_param(mdl_hdl,'RTWCPPFcnClass',interfaceConf);
            end




            try
                if hasStateflow
                    destMachineId=sf('find','all','machine.name',...
                    get_param(mdl_hdl,'Name'));

                    if~isempty(destMachineId)&&destMachineId>0




                        thisHdl.copyMachineParentedDataAndEvents(machineId,destMachineId);
                    end
                end
            catch exc
                mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,mdl_hdl,'AddStateflowCharts',exc,...
                thisHdl);
                error_occ=1;
                return;
            end
        end


        function checkInsidePeriodicFCSS(this,ssBlk)


            if strcmp(get_param(ssBlk,'Type'),'block_diagram')
                this.insidePeriodicFCSS=0;
            else
                portHdls=get_param(ssBlk,'PortHandles');
                if~isempty(portHdls.Trigger)
                    tpHdl=coder.internal.slBus('LocalGetBlockForPortPrm',portHdls.Trigger,'Handle');
                    if strcmp(get_param(tpHdl,'TriggerType'),'function-call')
                        if strcmp(get_param(tpHdl,'SampleTimeType'),'periodic')
                            this.insidePeriodicFCSS=1;
                        else
                            this.insidePeriodicFCSS=0;
                        end
                    else
                        this.checkInsidePeriodicFCSS(get_param(ssBlk,'Parent'));
                    end
                else
                    this.checkInsidePeriodicFCSS(get_param(ssBlk,'Parent'));
                end
            end
        end




        function compGlobalPortSampleTime(this,blockH)
            sample_time_expr=get_param(blockH,'SampleTime');





            [sampleTime,itExists]=slResolve(sample_time_expr,blockH);
            userSpecifiedSampleTime=true;
            if itExists
                if isempty(sampleTime)||(sampleTime(1)==-1)
                    userSpecifiedSampleTime=false;
                end

                if length(sampleTime)==1
                    sampleTime=[sampleTime,-1];
                end
            else
                sampleTime=[-1,-1];
                userSpecifiedSampleTime=false;
            end

            if all(sampleTime==[-1,-1])
                this.compiledSampleTime=get_param(blockH,'CompiledSampleTime');
            else
                this.compiledSampleTime=sampleTime;
            end

            if isequal(this.compiledSampleTime,[-1,-1])&&~this.exportFcns
                this.bUseGlobalSampleTime=1;
            else
                if sampleTime(1)>-1
                    this.bUseGlobalSampleTime=1;
                end

                if userSpecifiedSampleTime
                    this.bUseGlobalSampleTime=1;
                end
            end
        end



        function strPrm=getCompiledPortParam(thisHdl,inpH)
            strPrm.CompiledPortDataType=get_param(inpH,'CompiledPortAliasedThruDataType');
            strPrm.AliasPortDataType=get_param(inpH,'CompiledPortDataType');
            strPrm.CompiledPortDimensions=get_param(inpH,'CompiledPortDimensions');
            strPrm.SymbolicDimensions=coder.internal.Utilities.getCompiledSymbolicDims(inpH);
            strPrm.CompiledPortDimensionsMode=get_param(inpH,'CompiledPortDimensionsMode');
            strPrm.CompiledPortComplexSignal=get_param(inpH,'CompiledPortComplexSignal');
            strPrm.CompiledPortFrameData=get_param(inpH,'CompiledPortFrameData');

            strPrm=thisHdl.checkFunctionCallPortType(inpH,strPrm);

            strPrm.RTWSignalIdentifier=get_param(inpH,'CompiledRTWSignalIdentifier');
            strPrm.SignalObject=get_param(inpH,'CompiledSignalObject');
            strPrm.RTWStorageClass=get_param(inpH,'CompiledRTWStorageClass');
            if strcmp(strPrm.RTWStorageClass,'DefinedInTLC')
                strPrm.RTWStorageClass='Auto';
            end
            strPrm.RTWStorageTypeQualifier=get_param(inpH,...
            'CompiledRTWStorageTypeQualifier');








            strPrm.isFixPt=0;
            strPrm.isScaledDouble=0;
            dt=strPrm.CompiledPortDataType;
            if(fixed.internal.type.isNameOfTraditionalFixedPointType(dt))
                [~,isScaledDouble]=fixdt(dt);
                strPrm.isScaledDouble=isScaledDouble;
                strPrm.isFixPt=1;
            end

            if thisHdl.bUseGlobalSampleTime
                strPrm.CompiledSampleTime=thisHdl.compiledSampleTime;
            else
                strPrm.CompiledSampleTime=get_param(inpH,'CompiledSampleTime');
                if iscell(strPrm.CompiledSampleTime)
                    strPrm.CompiledSampleTime=strPrm.CompiledSampleTime{1};
                end
                if strcmp(strPrm.CompiledPortDataType,'fcn_call')
                    if strPrm.CompiledSampleTime(1)==-1&&strPrm.CompiledSampleTime(2)<=-1

                        sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.embeddedCoder);
                        try
                            inpHO=get_param(inpH,'Object');
                            actSrcP=inpHO.getActualSrc;
                            srcB=get_param(actSrcP(1,1),'Parent');
                            strPrm.CompiledSrcSampleTime=get_param(srcB,'CompiledSampleTime');
                            strPrm.CompiledSrcBlock=srcB;
                        catch exc %#ok<NASGU>
                        end
                        delete(sess);
                    end
                end
            end
        end









































        function[structBus,thisHdl]=getbus(thisHdl,inportH)
            thisHdl.bUseGlobalSampleTime=0;

            parentName=get_param(inportH,'Parent');
            parentH=get_param(parentName,'Handle');
            isSubSystem=strcmp(get_param(parentH,'BlockType'),'SubSystem');
            isOutPort=false;
            portType=get_param(inportH,'PortType');
            structBus.name='';
            structBus.portName='';
            structBus.portDesription='';
            structBus.requirementInfo='';

            if thisHdl.insidePeriodicFCSS
                thisHdl.compiledSampleTime=get_param(inportH,'CompiledSampleTime');
                thisHdl.bUseGlobalSampleTime=1;
            end

            inportBlkH=[];

            if isSubSystem
                inportBlkH=coder.internal.slBus('LocalGetBlockForPortPrm',inportH,'Handle');
                if any(strcmp(portType,{'trigger','enable','StateEnable','Reset'}))
                    thisHdl.compiledSampleTime=...
                    get_param(inportH,'CompiledSampleTime');
                    thisHdl.bUseGlobalSampleTime=1;
                else
                    thisHdl.compGlobalPortSampleTime(inportBlkH);
                end


                structBus.portName=coder.internal.RightClickBuild.locGetPortName(inportBlkH);
                structBus.portDesription=get_param(inportBlkH,'Description');
                structBus.requirementInfo=rmi.reqs2str(rmi.getReqs(inportBlkH));

                if strcmp(portType,'inport')
                    signalName=coder.internal.BusUtils.getSignalName(inportBlkH,inportH);
                    if~isempty(signalName)
                        if signalName(1)=='<'&&signalName(end)=='>'
                            signalName=signalName(2:end-1);
                        end
                        structBus.name=signalName;
                    end
                else
                    structBus.name=get_param(inportH,'Label');
                end
            else
                isOutPort=strcmp(get_param(parentH,'BlockType'),'Outport');
                if isOutPort
                    structBus.portName=coder.internal.RightClickBuild.locGetPortName(parentH);
                    structBus.name=coder.internal.BusUtils.getSignalName(parentH,inportH);
                    thisHdl.compGlobalPortSampleTime(parentH);
                else
                    signalName=coder.internal.BusUtils.getSignalName(parentH,inportH);
                    if~isempty(signalName)
                        if signalName(1)=='<'&&signalName(end)=='>'
                            signalName=signalName(2:end-1);
                        end
                        structBus.name=signalName;
                    end
                end
            end

            if thisHdl.useCompBusStruct
                busStruct=get_param(inportH,'CompiledBusStruct');
            else
                busStruct=get_param(inportH,'BusStruct');
            end

            compiledPortDT=get_param(inportH,'CompiledPortDataType');

            if isempty(busStruct)||strcmp(compiledPortDT,'fcn_call')
                isBusObject=false;
                if~isempty(inportBlkH)&&strcmp(portType,'inport')
                    [dtObject,itExists]=slResolve(compiledPortDT,inportBlkH,'variable');
                    isBusObject=(itExists&&isa(dtObject,'Simulink.Bus'));
                end
                if isBusObject
                    structBus.type=2;
                    structBus.node.hasBusObject=true;
                    structBus.node.busObject.name=compiledPortDT;
                    structBus.node.busObject.asStruct='on';
                else

                    structBus.type=1;
                    structBus.node.hasBusObject=false;
                end
                structBus.prm=thisHdl.getCompiledPortParam(inportH);
            else
                portNumber=get_param(inportH,'PortNumber');
                portName=structBus.portName;
                lineName=structBus.name;

                busObjectName=busStruct.busObjectName;
                busStruct.busObjectName=Simulink.ModelReference.Conversion.RightClickBuild.getBusObjectNameFromDTOPrefixDecorationName(busObjectName);

                if thisHdl.useCompBusStruct
                    structBus=thisHdl.convertBusStruct3(parentH,portNumber,busStruct,inportH);
                else
                    structBus=thisHdl.convertBusStruct2(parentH,portNumber,busStruct,inportH);
                end
                structBus.portName=portName;
                structBus.name=lineName;
            end
            if isempty(structBus.name)
                structBus.name='';
            end
            thisHdl.bUseGlobalSampleTime=0;

            if isSubSystem
                if any(strcmp(portType,{'trigger','enable','StateEnable','Reset'}))


                    structBus.blkSid=[get_param(bdroot(parentH),'Name'),':0'];
                else

                    if structBus.type==2&&structBus.node.isVirtualBus


                        structBus=coder.internal.BusUtils.populateBlkSid(structBus,[get_param(...
                        bdroot(parentH),'Name'),':0']);
                    else

                        structBus.blkSid=Simulink.ID.getSID(inportBlkH);
                    end
                end
            else
                if structBus.type==2&&structBus.node.isVirtualBus
                    structBus=coder.internal.BusUtils.populateBlkSid(structBus,[get_param(...
                    bdroot(parentH),'Name'),':0']);
                else
                    if isOutPort

                        structBus.blkSid=Simulink.ID.getSID(parentH);
                    else
                        structBus.blkSid=[get_param(bdroot(parentH),'Name'),':0'];
                    end
                end
            end
        end


        function[error_occ,hasStateflow,machineId,modelWasCompiled,err]=compileModel(thisHdl,strPorts)
            modelWasCompiled=false;
            hasStateflow=false;
            error_occ=0;
            err=[];
            machineId=0;
            try
                origSubsystemHdlForRightClickBuild=...
                get_param(thisHdl.mdlHdl,'SubsystemHdlForRightClickBuild');
                if(origSubsystemHdlForRightClickBuild<=0)
                    set_param(thisHdl.mdlHdl,'SubsystemHdlForRightClickBuild',thisHdl.Systems);
                    if(thisHdl.exportFcns)
                        set_param(thisHdl.mdlHdl,'GoingToExportFunctions','on')
                    end
                end
                origMdlName=get_param(thisHdl.mdlHdl,'Name');
                hasStateflow=true;
                [~,mexf]=inmem;
                sfIsHere=any(strcmp(mexf,'sf'));
                if(sfIsHere)
                    machineId=sf('find','all','machine.name',origMdlName);
                    if~isempty(machineId)&&machineId>0
                        newMachineId=sf('slsf','mdlInit',machineId);%#ok
                        hasStateflow=true;
                    end
                end
                origStrictBusMsg=get_param(thisHdl.mdlHdl,'StrictBusMsg');
                if strcmp(get_param(thisHdl.mdlHdl,'SimulationStatus'),'paused')

                    modelWasCompiled=true;
                    thisHdl.useCompBusStruct=...
                    strcmp(origStrictBusMsg,'ErrorLevel1');
                else



                    if~strcmp(origStrictBusMsg,'ErrorLevel1')||...
                        (thisHdl.ss2mdlForSLDV&&...
                        ~strcmp(origStrictBusMsg,'ErrorOnBusTreatedAsVector'))

                        if thisHdl.ss2mdlForSLDV
                            set_param(thisHdl.mdlHdl,'StrictBusMsg','ErrorOnBusTreatedAsVector');
                        else
                            set_param(thisHdl.mdlHdl,'StrictBusMsg','ErrorLevel1');
                        end
                        strictBusComp=false;
                    else
                        strictBusComp=true;
                    end
                    compileErr=[];
                    try
                        feval(origMdlName,[],[],[],'compileForSizes');
                        failedToCompile=false;
                    catch err
                        failedToCompile=true;
                        compileErr=err;
                        if strictBusComp
                            error_occ=1;
                        else
                            sllasterror([]);%#ok
                        end
                    end
                    if failedToCompile
                        disp(DAStudio.message('RTW:buildProcess:ModelFailedToCompile'));
                        set_param(thisHdl.mdlHdl,'StrictBusMsg',origStrictBusMsg);









                        if thisHdl.exportFcns||...
                            (thisHdl.ss2mdlForSLDV&&...
                            sldvshareprivate('util_is_DSM_BusProp',compileErr,'Simulink:Bus:SigHierPropSrcDstMismatchBusSrc'))
                            error_occ=1;
                        else
                            coder.internal.BusUtils.cacheCompiledBusInfo(thisHdl.Systems,strPorts,'off');
                            feval(origMdlName,[],[],[],'compileForSizes');
                        end
                    end
                    thisHdl.useCompBusStruct=~failedToCompile;
                end
            catch exc
                error_occ=1;
                err=exc;
            end
            set_param(thisHdl.mdlHdl,'SubsystemHdlForRightClickBuild',origSubsystemHdlForRightClickBuild);
            set_param(thisHdl.mdlHdl,'GoingToExportFunctions','off')
        end
    end

    methods(Access=private)
        function structBus=convertBusStruct2(thisHdl,dstBlk,dstPort,busStruct,inportH)
            structBus.name=busStruct.name;
            srcBlk=busStruct.src;
            structBus.node.isVirtualBus=strcmp(get_param(inportH,'CompiledBusType'),'VIRTUAL_BUS');
            structBus.prm=thisHdl.getCompiledPortParam(inportH);
            if~isempty(busStruct.busObjectName)
                structBus.type=2;
                structBus.node.hasBusObject=true;
                structBus.node.busObject.name=busStruct.busObjectName;
                structBus.node.busObject.asStruct=coder.internal.BusUtils.getBusSrcOutputAsStruct(srcBlk);
                ph=get_param(dstBlk,'PortHandles');
                structBus.prm=thisHdl.getCompiledPortParam(ph.Inport(dstPort));
            elseif isempty(busStruct.signals)
                structBus.type=1;
                structBus.node.hasBusObject=false;
                srcBlkType=get_param(srcBlk,'BlockType');
                srcPort=busStruct.srcPort;
                if strcmp(srcBlkType,'Inport')&&coder.internal.BusUtils.outputTypeIsBus(srcBlk)
                    structBus.type=2;
                    structBus.node.hasBusObject=true;
                    structBus.node.busObject.name=get_param(srcBlk,'BusObject');
                    structBus.node.busObject.asStruct=coder.internal.BusUtils.getBusSrcOutputAsStruct(srcBlk);
                    ph=get_param(dstBlk,'PortHandles');
                    structBus.prm=thisHdl.getCompiledPortParam(ph.Inport(dstPort));
                else
                    if srcPort>-1
                        ph=get_param(srcBlk,'PortHandles');
                        structBus.prm=thisHdl.getCompiledPortParam(ph.Outport(srcPort));
                    else
                        ph=get_param(dstBlk,'PortHandles');
                        structBus.prm=thisHdl.getCompiledPortParam(ph.Inport(dstPort));
                    end
                end
            else
                structBus.type=2;
                srcBlk=busStruct.src;
                srcType=get_param(srcBlk,'BlockType');
                numInputSignals=length(busStruct.signals);

                portHandles=get_param(srcBlk,'PortHandles');
                inportHandles=portHandles.Inport;
                if strcmp(srcType,'BusCreator')
                    if coder.internal.BusUtils.outputTypeIsBus(srcBlk)
                        structBus.node.hasBusObject=true;
                        structBus.node.busObject.name=get_param(srcBlk,'BusObject');
                        structBus.node.busObject.asStruct=coder.internal.BusUtils.getBusSrcOutputAsStruct(srcBlk);
                        ph=get_param(dstBlk,'PortHandles');
                        structBus.prm=thisHdl.getCompiledPortParam(ph.Inport(dstPort));
                    else





                        numInputPorts=length(inportHandles);
                        structBus.node.hasBusObject=false;

                        if numInputPorts==numInputSignals
                            for i=1:numInputPorts
                                if~isempty(busStruct.signals(i).signals)
                                    subBusStruct=get_param(inportHandles(i),'BusStruct');
                                    if isempty(subBusStruct)||isempty(subBusStruct.busObjectName)
                                        structBus.node.leafe{i}=...
                                        thisHdl.convertBusStruct2(srcBlk,i,busStruct.signals(i),inportHandles(i));
                                    else
                                        structBus.node.leafe{i}=...
                                        thisHdl.convertBusStruct2(srcBlk,i,subBusStruct,inportHandles(i));
                                    end
                                else



                                    structBus.node.leafe{i}=...
                                    thisHdl.convertBusStruct2(srcBlk,i,busStruct.signals(i),inportHandles(i));
                                end
                            end
                        else
                            for i=1:numInputSignals
                                structBus.node.leafe{i}=...
                                thisHdl.convertBusStruct2(srcBlk,i,busStruct.signals(i));
                            end
                        end
                    end
                else
                    structBus.node.hasBusObject=false;
                    for i=1:numInputSignals
                        portHandles=get_param(busStruct.signals(i).src,'PortHandles');
                        inportH=portHandles.Outport(busStruct.signals(i).srcPort);
                        structBus.node.leafe{i}=...
                        thisHdl.convertBusStruct2(srcBlk,i,busStruct.signals(i),inportH);
                    end
                end
            end
        end


        function structBus=convertBusStruct3(thisHdl,dstBlk,dstPort,busStruct,inportH)
            structBus.name=busStruct.name;
            srcBlk=busStruct.src;
            structBus.node.isVirtualBus=strcmp(get_param(inportH,'CompiledBusType'),'VIRTUAL_BUS');

            if strcmp(get_param(inportH,'CompiledBusType'),'NON_VIRTUAL_BUS')
                structBus.type=2;
                structBus.node.hasBusObject=true;
                structBus.node.busObject.name=busStruct.busObjectName;





                structBus.node.busObject.asStruct=coder.internal.BusUtils.getBusSrcOutputAsStruct(srcBlk);
                ph=get_param(dstBlk,'PortHandles');
                structBus.prm=thisHdl.getCompiledPortParam(ph.Inport(dstPort));
            elseif~isempty(busStruct.parentBusObjectName)
                structBus.type=1;
                structBus.node.hasBusObject=false;
                busObject=slResolve(busStruct.parentBusObjectName,busStruct.src,...
                'variable');
                busElement=[];
                for i=1:length(busObject.Elements)
                    if strcmp(busObject.Elements(i).Name,busStruct.name)
                        busElement=busObject.Elements(i);
                        break;
                    end
                end
                if isempty(busElement)
                    DAStudio.error('RTW:buildProcess:convertBusStruct3',...
                    busStruct.name,busStruct.parentBusObjectName);
                end
                structBus.prm=coder.internal.BusUtils.getBusElementPrm(srcBlk,busElement);
            elseif isempty(busStruct.signals)
                structBus.type=1;
                structBus.node.hasBusObject=false;
                srcBlkType=get_param(srcBlk,'BlockType');
                srcPort=busStruct.srcPort+1;
                if strcmp(srcBlkType,'Inport')&&coder.internal.BusUtils.outputTypeIsBus(srcBlk)
                    structBus.type=2;
                    structBus.node.hasBusObject=true;
                    structBus.node.busObject.name=get_param(srcBlk,'BusObject');
                    structBus.node.busObject.asStruct=coder.internal.BusUtils.getBusSrcOutputAsStruct(srcBlk);
                    ph=get_param(dstBlk,'PortHandles');
                    structBus.prm=thisHdl.getCompiledPortParam(ph.Inport(dstPort));
                else
                    if srcPort>-1
                        ph=get_param(srcBlk,'PortHandles');
                        structBus.prm=thisHdl.getCompiledPortParam(ph.Outport(srcPort));
                    else
                        ph=get_param(dstBlk,'PortHandles');
                        structBus.prm=thisHdl.getCompiledPortParam(ph.Inport(dstPort));
                    end
                end
            else
                structBus.type=2;
                srcBlk=busStruct.src;
                srcType=get_param(srcBlk,'BlockType');
                numInputSignals=length(busStruct.signals);

                portHandles=get_param(srcBlk,'PortHandles');
                inportHandles=portHandles.Inport;
                if strcmp(srcType,'BusCreator')&&coder.internal.BusUtils.outputTypeIsBus(srcBlk)
                    if strcmp(get_param(inportH,'CompiledBusType'),'VIRTUAL_BUS')
                        sigHierarchy=get_param(inportH,'SignalHierarchy');
                        structBus.node.hasBusObject=~isempty(sigHierarchy.BusObject);
                        for i=1:numInputSignals
                            structBus.node.leafe{i}=...
                            thisHdl.convertBusStruct3(srcBlk,i,busStruct.signals(i),inportHandles(i));
                        end
                    end
                    structBus.node.busObject.name=get_param(srcBlk,'BusObject');
                    structBus.node.busObject.asStruct=coder.internal.BusUtils.getBusSrcOutputAsStruct(srcBlk);
                else
                    sigHierarchy=get_param(inportH,'SignalHierarchy');
                    structBus.node.hasBusObject=~isempty(sigHierarchy.BusObject);
                    if strcmp(srcType,'BusSelector')&&strcmp(get_param(srcBlk,'OutputAsBus'),'on')
                        for i=1:numInputSignals
                            structBus.node.leafe{i}=...
                            thisHdl.convertBusStruct3(srcBlk,i,busStruct.signals(i),inportHandles(1));
                        end
                    else
                        for i=1:numInputSignals
                            structBus.node.leafe{i}=...
                            thisHdl.convertBusStruct3(srcBlk,i,busStruct.signals(i),inportHandles(i));
                        end
                    end
                end
                ph=get_param(dstBlk,'PortHandles');
                if strcmp(get_param(dstBlk,'BlockType'),'BusSelector')
                    structBus.prm=thisHdl.getCompiledPortParam(ph.Inport(1));
                else
                    structBus.prm=thisHdl.getCompiledPortParam(ph.Inport(dstPort));
                end
            end
        end
    end

    methods(Static,Access=private)


        function copyMachineParentedDataAndEvents(machineId,destMachineId)

            objIds=sf('DataOf',machineId);
            objIds=[sf('EventsOf',machineId),objIds];

            if~isempty(objIds)
                rt=sfroot;
                clp=sfclipboard;
                srcMachine=rt.find('-isa','Stateflow.Machine','Id',machineId);
                dstMachine=rt.find('-isa','Stateflow.Machine','Id',destMachineId);

                dataObj=[];
                for i=1:length(objIds)
                    dataObj=[srcMachine.find('Id',objIds(i)),dataObj];%#ok<AGROW>
                end

                clp.copy(dataObj);
                clp.pasteTo(dstMachine);

            end
        end


        function portName=locGetPortName(blkH)

            portName=get_param(blkH,'Name');


            if~any(strcmpi(get_param(blkH,'BlockType'),{'Inport','Outport'}))
                return;
            end


            if~Simulink.BlockDiagram.Internal.hasCompositePorts(get_param(get_param(blkH,'Parent'),'Handle'))
                return;
            end


            portName=get_param(blkH,'PortName');
        end
    end
end



