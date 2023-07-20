classdef(Sealed=true)RTOSInfo<codertarget.Info





    properties(Access='public')
        DefinitionFileName;

        Name='';
        TargetName='';
        IncludeFiles={};
        InitCall='';
        SemaphoreDataType='';
        SemaphoreInitCall='';
        SemaphorePostCall='';
        SemaphoreWaitCall='';
        SemaphoreDestroyCall='';
        TaskDataType='';
        TaskCreateCall='';
        TaskExitCall='';
        TaskJoinCall='';
        MaxNumTasks=99;
        MaxNumTimers=99;
        TaskPriorities=int16(1:99);
        TaskPriorityDescending=true;
        KernelLatency=0.0;
        TaskContextSaveTime=0.0;
        TaskContextRestoreTime=0.0;
        ModeChangeTime=0.0;
        EventDataType='';
        EventWaitCall='';
        EventAddBlockCall='';
        EventAddHandlerCall='';
        EventRestoreHandlerCall='';
        EventSendCall='';
        BaseRateTriggers={};
        BaseRatePriority='';
        SelectFcn='';
        BuildConfigurationInfo=[];
        EnableEdit=false;
    end

    properties(Access='public')
        MutexDataType='';
        MutexInitCall='';
        MutexLockCall='';
        MutexUnlockCall='';
        MutexTryLockCall='';
        MutexDestroyCall='';
    end
    methods(Access='public')
        function h=RTOSInfo(filePathName)
            if(nargin==1)
                h.DefinitionFileName=filePathName;
                h.deserialize;
            end
        end
        function register(h)
            h.serialize;
        end
        function ret=validate(h)
            ret=true;
            if isempty(h.Name)
                warning(message('codertarget:build:RTOSInfoNameEmpty'));
                ret=false;
            end
            if isempty(h.IncludeFiles)
                warning(message('codertarget:build:RTOSIncludeFilesEmpty'));
                ret=false;
            end
            if~iscvar(h.InitCall)
                warning(message('codertarget:build:RTOSInitCallInvalid'));
                ret=false;
            end
            if~iscvar(h.SemaphoreDataType)
                warning(message('codertarget:build:RTOSSemaphoreTypeInvalid'));
                ret=false;
            end
            if~iscvar(h.SemaphorePostCall)
                warning(message('codertarget:build:RTOSSemaphorePostCallInvalid'));
                ret=false;
            end
            if~iscvar(h.SemaphoreWaitCall)
                warning(message('codertarget:build:RTOSSemaphoreWaitCallInvalid'));
                ret=false;
            end
            if~iscvar(h.TaskDataType)
                warning(message('codertarget:build:RTOSTaskDataTypeInvalid'));
                ret=false;
            end
            if~iscvar(h.EventDataType)
                warning(message('codertarget:build:RTOSEventDataTypeInvalid'));
                ret=false;
            end
            if~iscvar(h.EventAddBlockCall)
                warning(message('codertarget:build:RTOSEventAddBlockCallInvalid'));
                ret=false;
            end
            if~iscvar(h.EventAddHandlerCall)
                warning(message('codertarget:build:RTOSEventAddHandlerCallInvalid'));
                ret=false;
            end
            if~iscvar(h.EventRestoreHandlerCall)
                warning(message('codertarget:build:RTOSEventRestoreHandlerCallInvalid'));
                ret=false;
            end
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
        function addIncludePath(h,fileName,varargin)
            if isempty(h.getBuildConfigurationInfo)
                valueToSet.Name=[h.Name,' LegacyBuildConfiguration'];
                h.addNewBuildConfigurationInfo(valueToSet);
            end
            bcInfo=h.getBuildConfigurationInfo(varargin{:});
            for i=1:numel(bcInfo)
                bcInfo(i).IncludePaths{end+1}=fileName;
            end
        end
        function ret=getIncludePaths(h,varargin)
            bcInfo=h.getBuildConfigurationInfo(varargin{:});
            ret={};
            for i=1:numel(bcInfo)
                ret=[ret,bcInfo(i).IncludePaths];%#ok<*AGROW>
            end
        end
        function ret=getInitCall(h)
            ret=h.InitCall;
        end
        function setInitCall(h,call)
            h.InitCall=call;
        end
        function ret=getDefines(h,varargin)
            bcInfo=h.getBuildConfigurationInfo(varargin{:});
            ret={};
            for i=1:numel(bcInfo)
                ret=[ret,bcInfo(i).Defines];
            end
        end
        function addDefine(h,define,varargin)
            if isempty(h.getBuildConfigurationInfo)
                valueToSet.Name=[h.Name,' LegacyBuildConfiguration'];
                h.addNewBuildConfigurationInfo(valueToSet);
            end
            bcInfo=h.getBuildConfigurationInfo(varargin{:});
            for i=1:numel(bcInfo)
                bcInfo(i).Defines{end+1}=define;
            end
        end
        function ret=getSemaphoreDataType(h)
            ret=h.SemaphoreDataType;
        end
        function setSemaphoreDataType(h,call)
            h.SemaphoreDataType=call;
        end
        function ret=getSemaphoreInitCall(h)
            ret=h.SemaphoreInitCall;
        end
        function setSemaphoreInitCall(h,call)
            h.SemaphoreInitCall=call;
        end
        function ret=getSemaphoreWaitCall(h)
            ret=h.SemaphoreWaitCall;
        end
        function setSemaphoreWaitCall(h,call)
            h.SemaphoreWaitCall=call;
        end
        function ret=getSemaphorePostCall(h)
            ret=h.SemaphorePostCall;
        end
        function setSemaphorePostCall(h,call)
            h.SemaphorePostCall=call;
        end
        function ret=getSemaphoreDestroyCall(h)
            ret=h.SemaphoreDestroyCall;
        end
        function setSemaphoreDestroyCall(h,call)
            h.SemaphoreDestroyCall=call;
        end
        function ret=getTaskDataType(h)
            ret=h.TaskDataType;
        end
        function setTaskDataType(h,call)
            h.TaskDataType=call;
        end
        function ret=getTaskCreateCall(h)
            ret=h.TaskCreateCall;
        end
        function setTaskCreateCall(h,call)
            h.TaskCreateCall=call;
        end
        function ret=getTaskExitCall(h)
            ret=h.TaskExitCall;
        end
        function setTaskExitCall(h,call)
            h.TaskExitCall=call;
        end
        function ret=getTaskJoinCall(h)
            ret=h.TaskJoinCall;
        end
        function setTaskJoinCall(h,call)
            h.TaskJoinCall=call;
        end
        function setEventDataType(h,call)
            h.EventDataType=call;
        end
        function ret=getEventDataType(h)
            ret=h.EventDataType;
        end
        function setEventWaitCall(h,call)
            h.EventWaitCall=call;
        end
        function ret=getEventWaitCall(h)
            ret=h.EventWaitCall;
        end
        function setEventAddBlockCall(h,call)
            h.EventAddBlockCall=call;
        end
        function ret=getEventAddBlockCall(h)
            ret=h.EventAddBlockCall;
        end
        function setEventAddHandlerCall(h,call)
            h.EventAddHandlerCall=call;
        end
        function ret=getEventAddHandlerCall(h)
            ret=h.EventAddHandlerCall;
        end
        function setEventRestoreHandlerCall(h,call)
            h.EventRestoreHandlerCall=call;
        end
        function ret=getEventRestoreHandlerCall(h)
            ret=h.EventRestoreHandlerCall;
        end
        function setEventSendCall(h,call)
            h.EventSendCall=call;
        end
        function ret=getEventSendCall(h)
            ret=h.EventSendCall;
        end
        function addBaseRateTrigger(h,name)
            h.BaseRateTriggers{end+1}=name;
        end
        function ret=getBaseRateTriggers(h)
            ret=h.BaseRateTriggers;
        end
        function setBaseRatePriority(h,value)
            h.BaseRatePriority=value;
        end
        function value=getBaseRatePriority(h)
            value=h.BaseRatePriority;
        end
        function setSelectFcn(h,fcnName)
            h.SelectFcn=fcnName;
        end
        function fcnName=getSelectFcn(h)
            fcnName=h.SelectFcn;
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
    methods(Static)
        function ret=isValidFuncCallIncludingArgs(call)
            openparpos=strfind(call,'(');
            closparpos=strfind(call,')');
            ret=~isempty(openparpos)&&~isempty(closparpos)&&...
            iscvar(call(1:openparpos-1))&&...
            (closparpos>openparpos);%#ok<*STREMP>
            if ret||~(closparpos-openparpos==1)
                argstr=strtrim(call(openparpos+1:closparpos-1));
                if isempty(strfind(argstr,','))

                    ret=iscvar(argstr);
                else

                    pos=strfind(argstr,',');
                    endpos=[pos-1,length(argstr)];
                    beg=1;
                    for i=1:numel(endpos)
                        arg=argstr(beg:endpos(i));
                        ret=ret&&iscvar(strtrim(arg));
                        beg=endpos(i)+2;
                    end
                end
            end
        end
        function ret=myGetSingleElement(xDoc,tag)
            ret='';
            allItems=xDoc.getElementsByTagName(tag);
            item=allItems.item(0);
            if~isempty(item)
                ret=char(item.getFirstChild.getData);
            end
        end
        function ret=myGetElementArray(xDoc,tag)
            ret={};
            allItems=xDoc.getElementsByTagName(tag);
            for i=0:allItems.getLength-1
                item=allItems.item(i);
                ret{end+1}=char(item.getFirstChild.getData);
            end
        end
        function mySetSingleElement(docNode,tag,value)
            if~isempty(value)
                docRootNode=docNode.getDocumentElement;
                thisElement=docNode.createElement(tag);
                thisElement.appendChild(docNode.createTextNode(value));
                docRootNode.appendChild(thisElement);
            end
        end
        function mySetElementArray(docNode,tag,elements)
            docRootNode=docNode.getDocumentElement;
            for i=1:numel(elements)
                name=codertarget.utils.replacePathSep(elements{i});
                thisElement=docNode.createElement(tag);
                thisElement.appendChild(docNode.createTextNode(name));
                docRootNode.appendChild(thisElement);
            end
        end
    end
    methods(Access='private')
        function ret=getShortDefinitionFileName(h)
            [~,name,ext]=fileparts(h.DefinitionFileName);
            ret=[name,ext];
        end
        function serialize(h)
            h.validate();
            docObj=h.createDocument('productinfo');
            docObj.item(0).setAttribute('version','3.0');
            h.mySetSingleElement(docObj,'name',h.getName);
            h.mySetSingleElement(docObj,'targetname',h.getTargetName);
            h.mySetElementArray(docObj,'includefile',h.getIncludeFiles);
            h.mySetSingleElement(docObj,'initcall',h.getInitCall);
            h.mySetSingleElement(docObj,'taskdatatype',h.getTaskDataType);
            h.mySetSingleElement(docObj,'taskcreatecall',h.getTaskCreateCall);
            h.mySetSingleElement(docObj,'taskexitcall',h.getTaskExitCall);
            h.mySetSingleElement(docObj,'taskjoincall',h.getTaskJoinCall);
            h.setElement(docObj,'maxnumtasks',h.MaxNumTasks);
            h.setElement(docObj,'maxnumtimers',h.MaxNumTimers);
            h.setElement(docObj,'taskpriorities',h.TaskPriorities);
            h.setElement(docObj,'taskprioritydescending',h.TaskPriorityDescending);
            h.setElement(docObj,'kernellatency',h.KernelLatency);
            h.setElement(docObj,'taskscontextsavetime',h.TaskContextSaveTime);
            h.setElement(docObj,'taskscontextrestoretime',h.TaskContextRestoreTime);
            h.setElement(docObj,'modechangetime',h.ModeChangeTime);
            h.mySetSingleElement(docObj,'mutexdatatype',get(h,'MutexDataType'));
            h.mySetSingleElement(docObj,'mutexinitcall',get(h,'MutexInitCall'));
            h.mySetSingleElement(docObj,'mutexlockcall',get(h,'MutexLockCall'));
            h.mySetSingleElement(docObj,'mutexunlockcall',get(h,'MutexUnlockCall'));
            h.mySetSingleElement(docObj,'mutextrylockcall',get(h,'MutexTryLockCall'));
            h.mySetSingleElement(docObj,'mutexdestroycall',get(h,'MutexDestroyCall'));
            h.mySetSingleElement(docObj,'semaphoredatatype',h.getSemaphoreDataType);
            h.mySetSingleElement(docObj,'semaphoreinitcall',h.getSemaphoreInitCall);
            h.mySetSingleElement(docObj,'semaphorewaitcall',h.getSemaphoreWaitCall);
            h.mySetSingleElement(docObj,'semaphorepostcall',h.getSemaphorePostCall);
            h.mySetSingleElement(docObj,'semaphoredestroycall',h.getSemaphoreDestroyCall);
            h.mySetSingleElement(docObj,'eventdatatype',h.getEventDataType);
            h.mySetSingleElement(docObj,'eventwaitcall',h.getEventWaitCall);
            h.mySetSingleElement(docObj,'eventblockcall',h.getEventAddBlockCall);
            h.mySetSingleElement(docObj,'eventaddhandlercall',h.getEventAddHandlerCall);
            h.mySetSingleElement(docObj,'eventrestorehandlercall',h.getEventRestoreHandlerCall);
            h.mySetSingleElement(docObj,'eventsendcall',h.getEventSendCall);
            h.mySetElementArray(docObj,'baseratetrigger',h.getBaseRateTriggers);
            h.mySetSingleElement(docObj,'baseratepriority',h.getBaseRatePriority);
            h.mySetSingleElement(docObj,'selectfcn',h.getSelectFcn);

            targetFolder=codertarget.target.getTargetFolder(h.getTargetName);
            if isempty(targetFolder)
                targetFolder='.';
            end
            rtosFolder=codertarget.target.getRTOSRegistryFolder(targetFolder);
            rtosName=fullfile(rtosFolder,h.getShortDefinitionFileName);
            rtosName=codertarget.utils.replacePathSep(rtosName);
            for i=1:numel(h.BuildConfigurationInfo)
                bcObj=h.BuildConfigurationInfo(i);
                fileName=codertarget.internal.makeValidFileName(bcObj.Name);
                absoluteFilename=[targetFolder,'/registry/rtos/',fileName,'.xml'];
                bcObj.DefinitionFileName=absoluteFilename;
                bcObj.serialize;
                relativeFileName=['$(TARGET_ROOT)','/registry/schedulers/',fileName,'.xml'];
                relativeFileName=codertarget.utils.replacePathSep(relativeFileName);
                h.setElement(docObj,'buildconfigurationinfofile',relativeFileName);
            end
            h.write(rtosName,docObj);
        end
        function deserializeBuildConfiguration(h,rootItem,version)
            switch(version)
            case '3.0'
                bcInfoFiles=h.myGetElementArray(rootItem,'buildconfigurationinfofile');

                [rtosFolder,~,~]=fileparts(h.DefinitionFileName);
                for i=1:numel(bcInfoFiles)
                    [~,name,ext]=fileparts(bcInfoFiles{i});
                    bcFile=fullfile(rtosFolder,[name,ext]);

                    bcObj=codertarget.attributes.BuildConfigurationInfo(bcFile);
                    h.addNewBuildConfigurationInfo(bcObj.get);
                end
            otherwise
                bcInfo.Name='Legacy Build Configuration';
                bcInfo.SourceFiles=h.myGetElementArray(rootItem,'sourcefile');
                bcInfo.IncludePaths=h.myGetElementArray(rootItem,'includepath');
                bcInfo.Defines=h.myGetElementArray(rootItem,'define');
                h.addNewBuildConfigurationInfo(bcInfo);
            end
        end
        function deserialize(h)
            docObj=h.read(h.DefinitionFileName);
            prodInfoList=docObj.getElementsByTagName('productinfo');
            rootItem=prodInfoList.item(0);
            prodInfo=struct;
            if rootItem.hasAttributes
                prodInfo.(char(rootItem.getAttributes.item(0).getName))=char(rootItem.getAttributes.item(0).getValue);
            end
            if~isfield(prodInfo,'version')
                prodInfo=struct('version','1.0');
            end
            h.Name=h.myGetSingleElement(docObj,'name');
            h.IncludeFiles=h.myGetElementArray(docObj,'includefile');
            h.InitCall=h.myGetSingleElement(docObj,'initcall');
            h.TaskDataType=h.myGetSingleElement(docObj,'taskdatatype');
            h.TaskCreateCall=h.myGetSingleElement(docObj,'taskcreatecall');
            h.TaskExitCall=h.myGetSingleElement(docObj,'taskexitcall');
            h.TaskJoinCall=h.myGetSingleElement(docObj,'taskjoincall');
            value=h.getElement(rootItem,'maxnumtasks','numeric');
            if isnumeric(value),h.MaxNumTasks=value;end
            value=h.getElement(rootItem,'maxnumtimers','numeric');
            if isnumeric(value),h.MaxNumTimers=value;end
            value=h.getElement(rootItem,'taskpriorities','cell');
            if iscell(value),h.TaskPriorities=int16(str2double(value));end
            value=h.getElement(rootItem,'taskprioritydescending','logical');
            if islogical(value),h.TaskPriorityDescending=value;end
            value=h.getElement(rootItem,'kernellatency','double');
            if isnumeric(value),h.KernelLatency=value;end
            value=h.getElement(rootItem,'taskscontextsavetime','double');
            if isnumeric(value),h.TaskContextSaveTime=value;end
            value=h.getElement(rootItem,'taskscontextrestoretime','double');
            if isnumeric(value),h.TaskContextRestoreTime=value;end
            value=h.getElement(rootItem,'modechangetime','double');
            if isnumeric(value),h.ModeChangeTime=value;end
            h.MutexDataType=h.myGetSingleElement(docObj,'mutexdatatype');
            h.MutexInitCall=h.myGetSingleElement(docObj,'mutexinitcall');
            h.MutexLockCall=h.myGetSingleElement(docObj,'mutexlockcall');
            h.MutexUnlockCall=h.myGetSingleElement(docObj,'mutexunlockcall');
            h.MutexTryLockCall=h.myGetSingleElement(docObj,'mutextrylockcall');
            h.MutexDestroyCall=h.myGetSingleElement(docObj,'mutexdestroycall');
            h.SemaphoreDataType=h.myGetSingleElement(docObj,'semaphoredatatype');
            h.SemaphoreInitCall=h.myGetSingleElement(docObj,'semaphoreinitcall');
            h.SemaphoreWaitCall=h.myGetSingleElement(docObj,'semaphorewaitcall');
            h.SemaphorePostCall=h.myGetSingleElement(docObj,'semaphorepostcall');
            h.SemaphoreDestroyCall=h.myGetSingleElement(docObj,'semaphoredestroycall');
            h.EventDataType=h.myGetSingleElement(docObj,'eventdatatype');
            h.EventWaitCall=h.myGetSingleElement(docObj,'eventwaitcall');
            h.EventAddBlockCall=h.myGetSingleElement(docObj,'eventblockcall');
            h.EventAddHandlerCall=h.myGetSingleElement(docObj,'eventaddhandlercall');
            h.EventRestoreHandlerCall=h.myGetSingleElement(docObj,'eventrestorehandlercall');
            h.EventSendCall=h.myGetSingleElement(docObj,'eventsendcall');
            h.BaseRateTriggers=h.myGetElementArray(docObj,'baseratetrigger');
            h.BaseRatePriority=h.myGetSingleElement(docObj,'baseratepriority');
            h.SelectFcn=h.myGetSingleElement(docObj,'selectfcn');
            value=h.getElement(rootItem,'enableedit','logical');
            if islogical(value),h.EnableEdit=value;end

            if isempty(h.BaseRateTriggers)
                h.BaseRateTriggers={'Operating system timer'};
            end
            h.deserializeBuildConfiguration(docObj,prodInfo.version);
            h.validate;
        end
    end
end














