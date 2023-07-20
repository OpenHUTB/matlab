


classdef(Hidden)ModelGenerator<handle

    properties(Constant,Access=private)
        InterfaceTableVariables={'AXIBlockName','AXIBlockHandle','DeviceName','RegisterOffset'}
    end
    properties(SetAccess=private,GetAccess=public)
HDLSystemInfo
TopModel
SoftwareSystemModel
HardwareBoard
    end

    properties(Access=private)
BuildDirectory
TempTopModel
AXIInterfaceBlocks
LIBIIOBlocks
        UseNewSemantics=false;
        AddIODataBlocks=false;
        MdlBlkLoadFcnCallback='';
    end


    methods
        function obj=ModelGenerator(topModel,socsysinfo,hardwareBoard,varargin)
            obj.TopModel=topModel;
            load_system(obj.TopModel);
            obj.HDLSystemInfo=socsysinfo;
            obj.BuildDirectory=obj.HDLSystemInfo.projectinfo.prj_dir;
            obj.HardwareBoard=hardwareBoard;
            if nargin>3
                p=inputParser;
                p.addParameter('AddIODataBlocks',false,@islogical);
                p.parse(varargin{:});
                obj.AddIODataBlocks=p.Results.AddIODataBlocks;
            end
        end

        function generateInterfaceModel(obj,modelName)

            if(nargin>1)&&ischar(modelName)
                obj.SoftwareSystemModel=modelName;
            else
                obj.SoftwareSystemModel=['gm_',obj.TopModel,'_software'];
            end
            disp(message('soc:utils:CreatingSystemModel',obj.SoftwareSystemModel).getString());
            createSoftwareModel(obj);
        end

        function generateInterfaceModelsForCPUs(obj,swModelName)
            obj.SoftwareSystemModel=swModelName;
            [taskMgrs,refModels]=soc.util.getESWRefModel(obj.TopModel);
            if~iscell(refModels)
                refModels={refModels};
                taskMgrs={taskMgrs};
            end
            cpunames=cell(size(taskMgrs));
            for i=1:numel(cpunames)
                cpunames{i}=codertarget.targethardware.getProcessingUnitName(refModels{i});
                if contains(obj.SoftwareSystemModel,cpunames{i})
                    relatedTaskMgrs=taskMgrs(i);
                    if numel(taskMgrs)>1
                        for j=1:numel(taskMgrs)
                            cs=getActiveConfigSet(refModels{j});
                            pu=codertarget.targethardware.getProcessingUnitInfo(cs);
                            if isempty(pu.PUAttachedTo),continue;end
                            if~isequal(pu.PUAttachedTo,cpunames{i}),continue;end
                            relatedTaskMgrs{end+1}=taskMgrs{j};%#ok<AGROW>
                        end
                    end
                    disp(message('soc:utils:CreatingSystemModel',obj.SoftwareSystemModel).getString());
                    createSoftwareModelForCPUs(obj,taskMgrs{i},relatedTaskMgrs,obj.SoftwareSystemModel);
                end
            end
        end
    end

    methods(Access=private)
        function findIIOBlocks(obj,allMdls)
            validateattributes(allMdls,{'cell'},{'nonempty'});
            libiioBlks={};
            for i=1:numel(allMdls)
                if strcmp(allMdls{i},obj.SoftwareSystemModel)
                    continue;
                end
                load_system(allMdls{i});


                if obj.UseNewSemantics
                    iioRdBlks=find_system(allMdls{i},'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Regexp','on','MaskType','Stream\s*Read');
                    iioWrBlks=find_system(allMdls{i},'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Regexp','on','MaskType','Stream\s*Write');
                else
                    iioRdBlks=find_system(allMdls{i},'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Regexp','on','MaskType','soc.*libiio.*read');
                    iioWrBlks=find_system(allMdls{i},'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Regexp','on','MaskType','soc.*libiio.*write');
                end
                libiioBlks=[iioRdBlks;iioWrBlks;libiioBlks];%#ok<AGROW>
            end
            obj.LIBIIOBlocks=libiioBlks;
        end

        function setIIOBlockParameters(obj)
            for i=1:numel(obj.LIBIIOBlocks)
                thisBlk=obj.LIBIIOBlocks{i};
                info=soc.util.getESBAXIInfo(thisBlk,obj.HDLSystemInfo);
                if isempty(info)
                    return;
                end
                driverNameSuffix='0';
                if contains(get_param(thisBlk,'MaskType'),'read','IgnoreCase',true)
                    postFix=':s2mm';
                elseif contains(get_param(thisBlk,'MaskType'),'write','IgnoreCase',true)
                    postFix=':mm2s';
                else
                    error('%s: Invalid Masktype: %s',getfullname(thisBlk),get_param(thisBlk,'MaskType'));
                end
                devName=[soc.if.CustomDeviceTreeUpdater.getValidDeviceName(info.ipcore_name),driverNameSuffix,postFix,driverNameSuffix];
                if(any(strcmpi(soc.util.getRefBlk(thisBlk),{'prociolib/Stream Write','prociolib/Stream Read'})))
                    obj.MdlBlkLoadFcnCallback=sprintf('%s\nset_param(''%s'', ''DeviceName'', ''%s'');',obj.MdlBlkLoadFcnCallback,l_getBlockName(thisBlk),devName);
                else
                    obj.MdlBlkLoadFcnCallback=sprintf('%s\nset_param(''%s'', ''devName'', ''%s'');',obj.MdlBlkLoadFcnCallback,l_getBlockName(thisBlk),devName);
                end
            end
        end


        function findAXIInterfaceBlocks(obj,allMdls)
            validateattributes(allMdls,{'cell'},{'nonempty'});
            axiBlks={};
            for i=1:numel(allMdls)
                if strcmp(allMdls{i},obj.SoftwareSystemModel)
                    continue;
                end
                load_system(allMdls{i});


                if obj.UseNewSemantics
                    axiRdBlks=find_system(allMdls{i},'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Regexp','on','MaskType','Register\s*Read');
                    axiWrBlks=find_system(allMdls{i},'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Regexp','on','MaskType','Register\s*Write');
                else
                    axiRdBlks=find_system(allMdls{i},'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Regexp','on','MaskType','soc\W\w+\WAXI.*Read');
                    axiWrBlks=find_system(allMdls{i},'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Regexp','on','MaskType','soc\W\w+\WAXI.*Write');
                end
                axiBlks=[axiRdBlks;axiWrBlks;axiBlks];%#ok<AGROW>
            end
            obj.AXIInterfaceBlocks=axiBlks;
        end


        function setAXIBlockParameters(obj)
            for i=1:numel(obj.AXIInterfaceBlocks)
                thisBlk=obj.AXIInterfaceBlocks{i};
                info=soc.util.getESBAXIInfo(thisBlk,obj.HDLSystemInfo);
                if isempty(info)
                    return;
                end
                driverNameSuffix='0';
                dutName=['/dev/',soc.if.CustomDeviceTreeUpdater.getValidDeviceName(info.ipcore_name),driverNameSuffix];
                obj.MdlBlkLoadFcnCallback=sprintf('%s\nset_param(''%s'', ''DeviceName'', ''%s'');',obj.MdlBlkLoadFcnCallback,l_getBlockName(thisBlk),dutName);
                if~isempty(info.offset)
                    if(any(strcmpi(soc.util.getRefBlk(thisBlk),{'prociolib/Register Write','prociolib/Register Read'})))
                        obj.MdlBlkLoadFcnCallback=sprintf('%s\nset_param(''%s'', ''OffsetAddress'', ''%s'');',obj.MdlBlkLoadFcnCallback,l_getBlockName(thisBlk),['hex2dec(''''',info.offset,''''')']);
                    else
                        obj.MdlBlkLoadFcnCallback=sprintf('%s\nset_param(''%s'', ''RegisterOffset'', ''%s'');',obj.MdlBlkLoadFcnCallback,l_getBlockName(thisBlk),['hex2dec(''''',info.offset,''''')']);
                    end
                end
            end
        end

        function createSoftwareModel(obj)


            taskMgr=soc.internal.connectivity.getTaskManagerBlock(obj.TopModel);
            createSoftwareModelForCPUs(obj,taskMgr,taskMgr,obj.SoftwareSystemModel);
        end

        function createSoftwareModelForCPUs(obj,cpuTaskMgr,allTaskMgrs,SoftwareSystemModel)

            if bdIsLoaded(SoftwareSystemModel)
                close_system(SoftwareSystemModel,0);
            end
            topMdlDirtyFlag=get_param(obj.TopModel,'Dirty');



            tskMgrHandles={};
            refMdls={};
            refProcs={};
            if~iscell(allTaskMgrs)
                allTaskMgrs={allTaskMgrs};
            end
            for k=1:numel(allTaskMgrs)
                thisTaskMgr=allTaskMgrs{k};
                taskMgrHandle=get_param(thisTaskMgr,'Handle');
                portH=get_param(thisTaskMgr,'LineHandles');
                allLineHandles=portH.Outport;
                allModelRefs=arrayfun(@(x)get_param(get_param(x,'NonVirtualDstPorts'),'Parent'),allLineHandles,'UniformOutput',false);
                allBlkNames=cellfun(@(x)get_param(x,'ModelName'),allModelRefs,'UniformOutput',false);
                allProcSysBlks=unique(allBlkNames);
                for i=1:numel(allProcSysBlks)


                    load_system(allProcSysBlks{i});


                    anyProcIOLibBlk=find_system(allProcSysBlks{i},'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Regexp','on','ReferenceBlock','prociolib.*');
                    anyProcInterLibBlk=find_system(allProcSysBlks{i},'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Regexp','on','ReferenceBlock','procinterlib.*');

                    anyBlks=[anyProcIOLibBlk;anyProcInterLibBlk];
                    if~isempty(anyBlks)
                        obj.UseNewSemantics=true;
                        break;
                    end
                end
                refProcs{end+1}=allProcSysBlks;%#ok<AGROW>
                tskMgrHandles{end+1}=taskMgrHandle;%#ok<AGROW>
                refMdls=[refMdls{:},allModelRefs];
            end
            allBlocks=[tskMgrHandles,unique(refMdls)];

            for i=1:numel(allBlocks)
                allBlocks{i}=obj.getSecondParentFromTop(allBlocks{i});
            end

            findAXIInterfaceBlocks(obj,allProcSysBlks);

            setAXIBlockParameters(obj);

            findIIOBlocks(obj,allProcSysBlks);

            setIIOBlockParameters(obj);

            soc.internal.connectivity.setIPCCodegenParams(obj.TopModel);
            donotGenerateSubsystem=all(cellfun(@(x)isequal(x,allBlocks{1}),allBlocks))&&...
            ~isequal(allBlocks{1},obj.TopModel);
            if donotGenerateSubsystem
                newSubsysName=allBlocks{1};
            else

                prevSettings=i_createSubsystem(obj.TopModel,allBlocks);
                newSubsysName=get_param(allBlocks{1},'Parent');

                revertTopModel=onCleanup(@()i_undoCreateSubsystem(newSubsysName,prevSettings));
            end
            resetDirtyFlag=onCleanup(@()set_param(obj.TopModel,'Dirty',topMdlDirtyFlag));
            newBd=new_system(SoftwareSystemModel,'Model',newSubsysName);
            load_system(newBd);
            set_param(newBd,'Location',get_param(obj.TopModel,'Location'));
            load_system(newBd);
            save_system(SoftwareSystemModel,fullfile(obj.HDLSystemInfo.projectinfo.prj_dir,SoftwareSystemModel));
            newBd=SoftwareSystemModel;
            if obj.AddIODataBlocks

                soc.internal.connectivity.addDataIOBlocks(newBd,obj.TopModel);


                addEventSourceBlocks(obj,newBd);


                replace_block(newBd,'SearchDepth',1,'BlockType','Inport','built-in/Ground','noprompt');
                replace_block(newBd,'SearchDepth',1,'BlockType','Outport','built-in/Terminator','noprompt');

            else

                addEventSourceBlocks(obj,newBd);


                replace_block(newBd,'SearchDepth',1,'BlockType','Inport','built-in/Ground','noprompt');
                replace_block(newBd,'SearchDepth',1,'BlockType','Outport','built-in/Terminator','noprompt');

                socSWModelName=allProcSysBlks{1};
                if obj.UseNewSemantics
                    messageTypes=obj.getMessageTypesFromWorkspace;
                    for iter=1:numel(messageTypes)
                        replaceDataMessageInports(obj,socSWModelName,['Bus: ',messageTypes{iter}]);
                    end
                else
                    replaceBusObjPorts(obj,socSWModelName);
                end
            end

            ConfigTaskManager(obj,newBd);

            for i=1:numel(refProcs)
                thisMdl=refProcs{i};
                refConfigMdl=thisMdl{1};
                refConfig=getActiveConfigSet(refConfigMdl);
                pu=codertarget.targethardware.getProcessingUnitInfo(refConfig);
                if~isempty(pu)&&...
                    isempty(pu.PUAttachedTo),break;end
            end
            load_system(refConfigMdl);
            newConfigObj=attachConfigSetCopy(newBd,refConfig,true);

            setActiveConfigSet(newBd,newConfigObj.Name);






            codertarget.data.setPeripheralInfo(getModel(newConfigObj),[]);

            set_param(newBd,'GenCodeOnly','off');
            set_param(newBd,'MultiTaskDSMMsg','error');
            set_param(newBd,'MultiTaskCondExecSysMsg','error');
            set_param(newBd,'CodeInterfacePackaging','Nonreusable function');

            set_param(newBd,'SolverType','Fixed-step');

            set_param(newBd,'StartFcn','warning(''off'', ''Simulink:Engine:ExtModeCannotDownloadParamBecauseNoHostToTarget'');');

            set_param(newBd,'StopFcn','warning(''on'', ''Simulink:Engine:ExtModeCannotDownloadParamBecauseNoHostToTarget'');');
            i_onHardwareSelectSWGen(getActiveConfigSet(newBd));
            if~isempty(obj.AXIInterfaceBlocks)
                hws=get_param(newBd,'modelworkspace');
                hws.DataSource='Model File';
                hws.assignin('InterfaceBlocks',obj.AXIInterfaceBlocks);



                obj.customAXIInterfaceSetting(obj.AXIInterfaceBlocks{1},newBd);
            end
            if Simulink.internal.useFindSystemVariantsMatchFilter()
                [~,allMdlRefBlks]=find_mdlrefs(newBd,'MatchFilter',@Simulink.match.activeVariants);
            else
                [~,allMdlRefBlks]=find_mdlrefs(newBd,'Variants','ActiveVariants');
            end
            for i=1:numel(allMdlRefBlks)
                thisMdlRef=allMdlRefBlks{i};
                thisModelName=get_param(thisMdlRef,'ModelName');
                obj.MdlBlkLoadFcnCallback=sprintf('load_system(''%s'');\n%s\nset_param(''%s'', ''Dirty'',''off'');',thisModelName,obj.MdlBlkLoadFcnCallback,thisModelName);

                eval(obj.MdlBlkLoadFcnCallback);

                set_param(thisMdlRef,'LoadFcn',obj.MdlBlkLoadFcnCallback);

                if~isequal(get_param(thisMdlRef,'SimulationMode'),'Normal')
                    set_param(thisMdlRef,'SimulationMode','Normal');
                end
            end
            textTopAlign=50;
            textLeftAlign=50;
            genText=sprintf('Software executable model generated from %s by SoC Builder on %s',obj.TopModel,datestr(now));
            IntroNote=Simulink.Annotation([newBd,'/',genText]);
            IntroNote.Position=[textLeftAlign,textTopAlign];
            IntroNote.FontSize=12;
            IntroNote.TeXMode='off';
            try
                Simulink.BlockDiagram.arrangeSystem(newBd,'FullLayout','true');
            catch ME %#ok<NASGU>

            end
            set_param(newBd,'ZoomFactor','FitSystem');

            set_param(newBd,'InheritedTsInSrcMsg','none');
            soc.internal.taskmanager.syncSchedules(newBd,false);
        end
        function busObjPort=replaceDataMessageInports(obj,cpuSWModelName,busType)
            load_system('proclib_internal');


            cpuSwMdlBlock=find_system(obj.SoftwareSystemModel,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','ModelReference','ModelName',cpuSWModelName);
            cpuSwMdlBlock=cpuSwMdlBlock{1};
            cpuSWMdl=get_param(cpuSwMdlBlock,'ModelName');
            load_system(cpuSWMdl);


            busPort=find_system(cpuSWMdl,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','Inport','OutDataTypeStr',busType);
            if~isempty(busPort)
                port_num=get_param(busPort{1},'Port');
                subsystemPorts=get_param(cpuSwMdlBlock,'PortHandles');
                this_inport=subsystemPorts.Inport(str2double(port_num));
                this_line=get_param(this_inport,'Line');
                busObjPort=get_param(get_param(this_line,'NonVirtualSrcPorts'),'Parent');
                blkName=get_param(busObjPort,'Name');
                replace_block(obj.SoftwareSystemModel,'SearchDepth',1,'BlockType','Ground','Name',blkName,'proclib_internal/Data Ground','noprompt')
                set_param(getfullname(busObjPort),'MessageBusType',busType);
            end
        end

        function busObjPort=replaceBusObjPorts(obj,esbModelName)
            busType='Bus: StreamSWReaderM2SBusObj';


            esbMdlBlock=find_system(obj.SoftwareSystemModel,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','ModelReference','ModelName',esbModelName);
            esbMdlBlock=esbMdlBlock{1};
            esbMdl=get_param(esbMdlBlock,'ModelName');
            parentBlk=obj.getSecondParentFromTop(esbMdlBlock);
            load_system(esbMdl);


            busPort=find_system(esbMdl,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','Inport','OutDataTypeStr',busType);
            if~isempty(busPort)
                port_num=get_param(busPort{1},'Port');
                subsystemPorts=get_param(parentBlk,'PortHandles');
                this_inport=subsystemPorts.Inport(str2double(port_num));
                this_line=get_param(this_inport,'Line');
                busObjPort=get_param(get_param(this_line,'NonVirtualSrcPorts'),'Parent');
                blkName=get_param(busObjPort,'Name');
                replace_block(obj.SoftwareSystemModel,'SearchDepth',1,'BlockType','Ground','Name',blkName,'built-in/Constant','noprompt');
                set_param([obj.SoftwareSystemModel,'/',blkName],'Value','0','OutDataTypeStr',busType);
            end
        end

        function addEventSourceBlocks(obj,topModel)%#ok<INUSL>
            load_system('prociodatalib');
            closeLibrary=onCleanup(@()close_system('prociodatalib'));
            taskMgr=soc.internal.connectivity.getTaskManagerBlock(topModel);
            if~iscell(taskMgr)
                taskMgr={taskMgr};
            end
            for i=1:numel(taskMgr)
                taskMgrPos=get_param(taskMgr{i},'Position');
                portH=get_param(taskMgr{i},'PortHandles');
                for j=1:numel(portH.Inport)
                    blk=get_param(get_param(get_param(portH.Inport(j),'Line'),'NonVirtualSrcPorts'),'Parent');
                    newblk=replace_block(topModel,'SearchDepth',1,'BlockType','Inport','Name',get_param(blk,'Name'),'prociodatalib/Event Source','noprompt');
                    if~isempty(newblk)
                        newblk=newblk{1};
                        set_param(newblk,'InputSource','From dialog');
                        set_param(newblk,'SampleTime','-1');
                        set_param(newblk,'Position',taskMgrPos);
                    end
                end
            end
        end
        function ConfigTaskManager(obj,topModel)%#ok<INUSL>
            taskMgr=soc.internal.connectivity.getTaskManagerBlock(topModel);
            if~iscell(taskMgr)
                taskMgr={taskMgr};
            end
            for i=1:numel(taskMgr)
                soc.internal.taskmanager.setTaskEventManuallyAssigned(taskMgr{i});
            end
        end
    end

    methods(Static,Hidden)
        function ret=getMessageTypesFromWorkspace()
            ret={};
            supportedTypes=convertStringsToChars(string(enumeration('HWSWMetadataID')));
            for i=1:numel(supportedTypes)
                msgType=evalin('base',sprintf('whos (''%s*'')',supportedTypes{i}));
                if~isempty(msgType)
                    ret=[ret,{msgType.name}];%#ok<AGROW>
                end
            end
        end

        function ret=getSecondParentFromTop(sys)
            blksInHier=regexp(getfullname(sys),'\/','split');
            if(numel(blksInHier)>2)
                ret=get_param([blksInHier{1},'/',blksInHier{2}],'Handle');
            else
                ret=get_param(sys,'Handle');
            end
        end

        function tpModelName=createTemporaryModel(origModel,fileLoc)
            tpModelName=tempname(fileLoc);
            load_system(origModel);
            src=which(origModel);
            [~,~,ext]=fileparts(src);
            dst=[tpModelName,ext];
            [success,msg,id]=copyfile(src,dst,'f');
            if~success
                error(id,msg);
            end
            load_system(tpModelName);
        end

        function cleanupTempModel(tpModelFullPath)
            close_system(tpModelFullPath,0);
            delete([tpModelFullPath,'.*']);
        end

        function customAXIInterfaceSetting(blk,~)
            blkref=fileparts(soc.util.getRefBlk(blk));
            switch(lower(blkref))
            case 'zynqiolib'
            case 'intelsoclib'
            otherwise
            end
        end

    end
end

function prevSettings=i_createSubsystem(topModel,blockHandleCellArray)
    prevSettings=struct('AnnotationHandles',[],...
    'AnnotationPositions',[],...
    'TopModelLocation',[],...
    'Blocks',[],...
    'BlockPositions',[]);
    prevSettings.AnnotationHandles=find_system(topModel,'FindAll','on','SearchDepth',1,'type','annotation');
    if~isempty(prevSettings.AnnotationHandles)
        prevSettings.AnnotationPositions=arrayfun(@(x)get_param(x,'Position'),prevSettings.AnnotationHandles,'UniformOutput',false);
    end
    prevSettings.Blocks=find_system(topModel,'SearchDepth',1);
    prevSettings.Blocks=prevSettings.Blocks(2:end);
    prevSettings.BlockPositions=cellfun(@(x)get_param(x,'Position'),prevSettings.Blocks,'UniformOutput',false);
    prevSettings.TopModelLocation=get_param(topModel,'Location');
    Simulink.BlockDiagram.createSubsystem([blockHandleCellArray{:}])
end


function i_undoCreateSubsystem(newSubsysName,prevSettings)
    rootModel=bdroot(newSubsysName);
    Simulink.BlockDiagram.expandSubsystem(newSubsysName);

    [~,sname]=fileparts(newSubsysName);


    ah=find_system(rootModel,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FindAll','on','AnnotationType','area_annotation','Name',sname);
    delete(ah);

    for i=1:numel(prevSettings.AnnotationHandles)
        set_param(prevSettings.AnnotationHandles(i),'Position',prevSettings.AnnotationPositions{i});
    end
    for i=1:numel(prevSettings.Blocks)
        set_param(prevSettings.Blocks{i},'Position',prevSettings.BlockPositions{i});
    end
    set_param(rootModel,'Location',prevSettings.TopModelLocation);
end

function i_onHardwareSelectSWGen(hCS)


    try
        if~strcmpi(get_param(hCS,'SolverType'),'Fixed-step')

            return;
        end

        if strcmpi(get_param(hCS,'SampleTimeConstraint'),'STIndependent')

            return;
        end
        osName=codertarget.targethardware.getTargetRTOS(hCS);



        hCS.setPropEnabled('PositivePriorityOrder',true);
        switch(lower(osName))
        case{'linux','vxworks'}

            set_param(hCS,'PositivePriorityOrder','on');
        end


        set_param(hCS,'EnableMultiTasking','on');
    catch ME
        warning(ME.identifier,'%s',ME.message);
    end

end

function blkName=l_getBlockName(blk)


    blkName=regexprep(getfullname(blk),'\n',' ');
end





