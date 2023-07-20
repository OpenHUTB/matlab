classdef(Sealed=true)SchedulerInfo<codertarget.Info





    properties(Access='public')
        DefinitionFileName;

        Name='';
        TargetName='';
        ConfigureStartCall='';
        ConfigureStopCall='';
        InterruptEnableCall='';
        InterruptDisableCall='';
        SourceFiles={};
        IncludeFiles={};
        BuildConfigurationInfo=[];
    end

    methods(Access='public')
        function h=SchedulerInfo(filePathName)
            if(nargin==1)
                h.DefinitionFileName=filePathName;
                h.deserialize;
            end
        end
        function register(h)
            h.serialize;
        end
        function registerHWI(h,baremetalScheduler,targetRoot)
            h.serializeHWI(baremetalScheduler,targetRoot);
        end
        function ret=getDefinitionFileName(h)
            ret=h.DefinitionFileName;
        end
        function setDefinitionFileName(h,name)
            h.DefinitionFileName=name;
        end
        function ret=getName(h)
            ret=h.Name;
        end
        function setName(h,name)
            h.Name=name;
        end
        function ret=getTargetName(h)
            ret=h.TargetName;
        end
        function setTargetName(h,name)
            h.TargetName=name;
        end
        function ret=getConfigureStartCall(h)
            ret=h.ConfigureStartCall;
        end
        function setConfigureStartCall(h,call)
            h.ConfigureStartCall=call;
        end
        function ret=getConfigureStopCall(h)
            ret=h.ConfigureStopCall;
        end
        function setConfigureStopCall(h,call)
            h.ConfigureStopCall=call;
        end
        function ret=getInterruptEnableCall(h)
            ret=h.InterruptEnableCall;
        end
        function setInterruptEnableCall(h,call)
            h.InterruptEnableCall=call;
        end
        function ret=getInterruptDisableCall(h)
            ret=h.InterruptDisableCall;
        end
        function setInterruptDisableCall(h,call)
            h.InterruptDisableCall=call;
        end
        function ret=getSourceFiles(h,varargin)
            bcInfo=h.getBuildConfigurationInfo(varargin{:});
            ret={};
            for i=1:numel(bcInfo)
                ret=[ret,bcInfo(i).SourceFiles];%#ok<*AGROW>
            end
        end
        function addSourceFile(h,fileName,varargin)
            if isempty(h.getBuildConfigurationInfo)
                valueToSet.Name=[h.Name,' LegacyBuildConfiguration'];
                h.addNewBuildConfigurationInfo(valueToSet);
            end
            bcInfo=h.getBuildConfigurationInfo(varargin{:});
            for i=1:numel(bcInfo)
                bcInfo(i).SourceFiles{end+1}=fileName;
            end
        end
        function ret=getIncludeFiles(h)
            ret=h.IncludeFiles;
        end
        function addIncludeFile(h,file)
            h.IncludeFiles{end+1}=file;
        end
    end
    methods(Access='public',Hidden)
        function addNewBuildConfigurationInfo(h,valueToSet)
            bcObj=codertarget.attributes.BuildConfigurationInfo;
            bcObj.set(valueToSet);
            h.addNewElementToArrayProperty(h,'BuildConfigurationInfo',bcObj);
        end
        function allBCs=getBuildConfigurationInfo(h,varargin)
            p=inputParser;
            p.addParameter('os','any');
            p.addParameter('toolchain','any');
            p.parse(varargin{:});
            res=p.Results;
            allBCs=[];
            for i=1:numel(h.BuildConfigurationInfo)
                bcObj=h.BuildConfigurationInfo(i);
                isSupportedOS=isequal(res.os,'any')||...
                isequal(bcObj.SupportedOperatingSystems,{'all'})||...
                ismember(res.os,bcObj.SupportedOperatingSystems);
                isSupportedToolchain=isequal(res.toolchain,'any')||...
                isequal(bcObj.SupportedToolchains,{'all'})||...
                ismember(res.toolchain,bcObj.SupportedToolchains);
                if isSupportedOS&&isSupportedToolchain
                    allBCs=[allBCs,bcObj];
                end
            end
        end
    end
    methods(Access='private')
        function ret=getShortDefinitionFileName(h)
            [~,name,ext]=fileparts(h.DefinitionFileName);
            ret=[name,ext];
        end
        function serialize(h)
            docObj=h.createDocument('productinfo');
            docObj.item(0).setAttribute('version','3.0');
            h.setElement(docObj,'name',h.getName);
            h.setElement(docObj,'targetname',h.getTargetName);
            h.setElement(docObj,'configurestartcall',h.getConfigureStartCall);
            h.setElement(docObj,'configurestopcall',h.getConfigureStopCall);
            h.setElement(docObj,'interruptenablecall',h.getInterruptEnableCall);
            h.setElement(docObj,'interruptdisablecall',h.getInterruptDisableCall);
            h.setElement(docObj,'sourcefile',h.getSourceFiles);
            h.setElement(docObj,'includefile',h.getIncludeFiles);
            targetFolder=codertarget.target.getTargetFolder(h.getTargetName);
            if isempty(targetFolder)
                targetFolder='.';
            end
            schedulerFolder=codertarget.target.getSchedulerRegistryFolder(targetFolder);
            schedulerName=fullfile(schedulerFolder,h.getShortDefinitionFileName);
            schedulerName=codertarget.utils.replacePathSep(schedulerName);
            for i=1:numel(h.BuildConfigurationInfo)
                bcObj=h.BuildConfigurationInfo(i);
                fileName=codertarget.internal.makeValidFileName(bcObj.Name);
                absoluteFilename=[targetFolder,'/registry/schedulers/',fileName,'.xml'];
                bcObj.DefinitionFileName=absoluteFilename;
                bcObj.serialize;
                relativeFileName=['$(TARGET_ROOT)','/registry/schedulers/',fileName,'.xml'];
                relativeFileName=codertarget.utils.replacePathSep(relativeFileName);
                h.setElement(docObj,'buildconfigurationinfo',relativeFileName);
            end
            h.write(schedulerName,docObj);
        end
        function serializeHWI(h,scheduler,targetRoot)
            interruptTaskType={};
            interruptGroupName={};
            interruptName={};
            interruptNumber={};
            interruptPriority={};
            interruptTrigger={};
            interruptTaskPeriod={};
            isrName={};
            docObj=h.createDocument('InterruptInfo');
            interruptInfo=docObj.getDocumentElement;
            for interruptGroupidx=1:numel(scheduler.InterruptHandlers{1}.Interrupts)
                obj=scheduler.InterruptHandlers{1}.Interrupts{interruptGroupidx};
                groupNameIdx=find(ismember(interruptGroupName,obj.Group),1);
                if isempty(groupNameIdx)
                    interruptGroupName{end+1}=obj.Group;
                    interruptName{end+1}={obj.Name};
                    interruptTaskType{end+1}={obj.TaskType};
                    if numel(obj.Number)==1
                        interruptNumber{end+1}={num2str(obj.Number)};
                    else
                        interruptNumber{end+1}={['[',num2str(obj.Number),']']};
                    end
                    interruptPriority{end+1}={num2str(obj.TaskPriority)};
                    isrName{end+1}={obj.IsrName};
                    if strcmp(obj.TaskType,'Event-driven')
                        obj.Trigger=scheduler.cell2str(obj.Trigger,';');

                        interruptTrigger{end+1}={obj.Trigger};
                        interruptTaskPeriod{end+1}={''};
                    elseif strcmp(obj.TaskType,'Timer-driven')

                        interruptTaskPeriod{end+1}={num2str(obj.TaskPeriod)};
                        interruptTrigger{end+1}={''};
                    end
                else
                    interruptName{groupNameIdx}{end+1}=obj.Name;
                    interruptTaskType{groupNameIdx}{end+1}=obj.TaskType;
                    if numel(obj.Number)==1
                        interruptNumber{groupNameIdx}{end+1}=num2str(obj.Number);
                    else
                        interruptNumber{groupNameIdx}{end+1}=['[',num2str(obj.Number),']'];
                    end
                    interruptPriority{groupNameIdx}{end+1}=num2str(obj.TaskPriority);
                    isrName{groupNameIdx}{end+1}=obj.IsrName;
                    if strcmp(obj.TaskType,'Event-driven')
                        obj.Trigger=scheduler.cell2str(obj.Trigger,';');
                        interruptTrigger{groupNameIdx}{end+1}=obj.Trigger;
                        interruptTaskPeriod{groupNameIdx}{end+1}='';
                    elseif strcmp(obj.TaskType,'Timer-driven')
                        interruptTaskPeriod{groupNameIdx}{end+1}=num2str(obj.TaskPeriod);
                        interruptTrigger{groupNameIdx}{end+1}='';
                    end
                end
            end
            SourceFile=scheduler.cell2str(scheduler.InterruptHandlers{1}.SourceFiles,';');
            HeaderFile=scheduler.cell2str(scheduler.InterruptHandlers{1}.HeaderFiles,';');
            IncludePath=scheduler.cell2str(scheduler.InterruptHandlers{1}.IncludePaths,';');
            IntDefPrefix=scheduler.InterruptHandlers{1}.IntDefPrefix;
            IntDefSuffix=scheduler.InterruptHandlers{1}.IntDefSuffix;



            filename=fullfile(targetRoot,'registry','interrupts',[matlabshared.targetsdk.internal.makeValidFileName(scheduler.InterruptHandlers{1}.Name),'.xml']);
            filename=codertarget.utils.replacePathSep(filename);
            libraryName=matlabshared.targetsdk.internal.makeValidFileName(scheduler.InterruptHandlers{1}.LibraryName);
            libraryPath=scheduler.InterruptHandlers{1}.LibraryPath;
            HeaderFile=[HeaderFile,';','MW_',libraryName,'_int_function.h'];
            IncludePath=[IncludePath,';',fullfile(targetRoot,'include')];
            scheduler.mySetSingleElement(docObj,'BlockName',(scheduler.InterruptHandlers{1}.Name),interruptInfo);
            scheduler.mySetSingleElement(docObj,'LibName',libraryName,interruptInfo);
            scheduler.mySetSingleElement(docObj,'LibPath',libraryPath,interruptInfo);

            scheduler.mySetSingleElement(docObj,'SupportDropOverrunTask',(num2str(scheduler.InterruptHandlers{1}.SupportDropOverrunTask)),interruptInfo);
            scheduler.mySetSingleElement(docObj,'SourceFile',SourceFile,interruptInfo);
            scheduler.mySetSingleElement(docObj,'HeaderFile',HeaderFile,interruptInfo);
            scheduler.mySetSingleElement(docObj,'IncludePath',IncludePath,interruptInfo);
            scheduler.mySetSingleElement(docObj,'IntDefPrefix',IntDefPrefix,interruptInfo);
            scheduler.mySetSingleElement(docObj,'IntDefSuffix',IntDefSuffix,interruptInfo);
            isExistTimerDriven=0;
            allInterruptName={};
            for interruptGroupidx=1:numel(interruptGroupName)
                IrqGroupProduct=scheduler.mySetSingleElement(docObj,'IrqGroup','',interruptInfo);
                scheduler.mySetSingleElement(docObj,'Name',(interruptGroupName{interruptGroupidx}),IrqGroupProduct);
                for IrqInfoidx=1:numel(interruptName{interruptGroupidx})
                    allInterruptName{end+1}=interruptName{interruptGroupidx}{IrqInfoidx};
                    IrqInfoProduct=scheduler.mySetSingleElement(docObj,'IrqInfo','',IrqGroupProduct);
                    scheduler.mySetSingleElement(docObj,'IrqTaskType',interruptTaskType{interruptGroupidx}{IrqInfoidx},IrqInfoProduct);
                    scheduler.mySetSingleElement(docObj,'IrqName',interruptName{interruptGroupidx}{IrqInfoidx},IrqInfoProduct);
                    scheduler.mySetSingleElement(docObj,'IrqNumber',interruptNumber{interruptGroupidx}{IrqInfoidx},IrqInfoProduct);
                    scheduler.mySetSingleElement(docObj,'IrqPriority',interruptPriority{interruptGroupidx}{IrqInfoidx},IrqInfoProduct);
                    scheduler.mySetSingleElement(docObj,'IrqIsrName',isrName{interruptGroupidx}{IrqInfoidx},IrqInfoProduct);
                    if~isempty(interruptTrigger{interruptGroupidx}{IrqInfoidx})
                        scheduler.mySetSingleElement(docObj,'IrqTrigger',interruptTrigger{interruptGroupidx}{IrqInfoidx},IrqInfoProduct);
                    else
                        scheduler.mySetSingleElement(docObj,'IrqTaskPeriod',interruptTaskPeriod{interruptGroupidx}{IrqInfoidx},IrqInfoProduct);
                        isExistTimerDriven=1;
                    end
                end
            end



            h.write(filename,docObj);
            blockInfo=targetsdk.blocks.interruptsRead(filename,'Event-driven');
            libraryName=blockInfo.LibName;
            blockName=blockInfo.BlockName;
            new_system(libraryName,'Library');
            open_system(libraryName);
            blk=add_block('HWIBlockTemplate/Hardware Interrupt',[libraryName,'/',blockName]);
            set_param(blk,'xmlPath',filename);
            set_param(blk,'incFile',HeaderFile);
            set_param(blk,'srcFile',SourceFile);
            set_param(blk,'incPath',IncludePath);
            set_param(blk,'IntDefPrefix',IntDefPrefix);
            set_param(blk,'IntDefSuffix',IntDefSuffix);

            set_param(libraryName,'Lock','on');

            newHeaderFile=[fullfile(targetRoot,'include'),'\MW_',libraryName,'_int_function.h'];
            createHeaderFile(h,newHeaderFile,allInterruptName,isExistTimerDriven,interruptTrigger);
            save_system(libraryName,[libraryPath,'/',libraryName]);
        end
        function createHeaderFile(~,headerFile,intNameList,timer_driven_task,interruptGroupTrigger)
            try
                fid=fopen(headerFile,'w');
                if fid~=-1
                    for idx=1:numel(interruptGroupTrigger)
                        for idx1=1:numel(interruptGroupTrigger{idx})
                            if~isempty(interruptGroupTrigger{idx}{idx1})
                                trigger=strsplit(interruptGroupTrigger{idx}{idx1},';');
                                for idx2=1:numel(trigger)
                                    fprintf(fid,['#define ',trigger{idx2},' ',num2str(idx2-1),'\n']);
                                end
                            end
                        end
                    end
                    fprintf(fid,'void usr_Interrupt_ModelInitialize(int16_T, uint16_T , int16_T, uint16_T);\n');
                    fprintf(fid,'void usr_Interrupt_ModelTerminate(uint16_T);\n');
                    if timer_driven_task
                        fprintf(fid,'void usr_Interrupt_TimerInitialize(uint16_T, real_T);\n');
                        fprintf(fid,'void usr_Interrupt_TimerStart(uint16_T);\n');
                        fprintf(fid,'void usr_Interrupt_TimerClose(uint16_T);\n');
                    end
                    for idx=1:numel(intNameList)
                        fprintf(fid,['boolean_T usr_',intNameList{idx},'_IsrEntry(uint16_T);\n']);
                        fprintf(fid,['boolean_T usr_',intNameList{idx},'_IsrExit(uint16_T);\n']);
                    end
                    fclose(fid);
                end
            catch ME
                if fid~=-1
                    fclose(fid);
                end
                error(message('codertarget:hwisdkblock:HeaderFileNotCreated',headerFile));
            end
        end
        function deserializeBuildConfiguration(h,rootItem)
            switch(version)
            case '3.0'
                bcInfoFiles=h.getElement(rootItem,'buildconfigurationinfo','cell');
                targetFolder=codertarget.target.getTargetFolder(h.getTargetName);
                for i=1:numel(bcInfoFiles)
                    bcFile=strrep(bcInfoFiles{i},'$(TARGET_ROOT)',targetFolder);
                    bcObj=codertarget.attributes.BuildConfigurationInfo(bcFile);
                    h.addNewBuildConfigurationInfo(bcObj.get);
                end
            otherwise
                bcInfo.Name='Legacy Build Configuration';
                bcInfo.SourceFiles=h.getElement(rootItem,'sourcefile','cell');
                h.addNewBuildConfigurationInfo(bcInfo);
            end
        end
        function deserialize(h)
            docObj=h.read(h.DefinitionFileName);
            prodInfoList=docObj.getElementsByTagName('productinfo');
            rootItem=prodInfoList.item(0);
            h.Name=h.getElement(rootItem,'name','char');
            h.TargetName=h.getElement(rootItem,'targetname','char');
            h.ConfigureStartCall=h.getElement(rootItem,'configurestartcall','char');
            h.ConfigureStopCall=h.getElement(rootItem,'configurestopcall','char');
            h.InterruptEnableCall=h.getElement(rootItem,'interruptenablecall','char');
            h.InterruptDisableCall=h.getElement(rootItem,'interruptdisablecall','char');
            h.IncludeFiles=h.getElement(rootItem,'includefile','cell');
            h.deserializeBuildConfiguration(rootItem);
        end
    end
end
