classdef IPCInfo<codertarget.Info





    properties(Dependent)
TargetFolder
    end

    properties
Name
TargetName
        DefinitionFileName='';
        Channels=struct('Min',1,'Max',1)
        Buffers=struct('Min',1,'Max',1)
        BufferLength=struct('Min',1,'Max',1)
        BufferSize=1
SourceFiles
IncludeFiles
        Type=codertarget.ipc.IPCTypes.UNSPECIFIED
    end

    properties(Access='public',Hidden)
BuildConfigurationInfo
    end

    methods
        function h=IPCInfo(varargin)
            p=inputParser;
            p.addOptional('filePathName','',@isfile);
            p.addOptional('ipcName','',@ischar);
            p.parse(varargin{:})

            h.DefinitionFileName=fullfile(p.Results.filePathName);
            h.Name=p.Results.ipcName;
            if~isempty(h.DefinitionFileName)
                h.deserialize();
            end
        end

        function set.DefinitionFileName(h,name)
            validateattributes(name,{'char','string'},{});
            h.DefinitionFileName=name;
        end
        function name=get.DefinitionFileName(h)
            name=h.DefinitionFileName;
        end
        function out=get.TargetFolder(h)
            out=fileparts(fileparts(fileparts(h.DefinitionFileName)));
        end
        function set.Name(h,name)
            validateattributes(name,{'char','string'},{});
            h.Name=name;
        end
        function name=get.Name(h)
            name=h.Name;
        end
        function set.Type(h,type)
            validateattributes(type,{'codertarget.ipc.IPCTypes'},{'nonempty'});
            h.Type=type;
        end
        function type=get.Type(h)
            type=codertarget.ipc.IPCTypes(h.Type);
        end

        function ret=get.SourceFiles(h)
            ret=h.SourceFiles;
        end
        function set.SourceFiles(h,name)
            h.SourceFiles=name;
        end
        function ret=get.IncludeFiles(h)
            ret=h.IncludeFiles;
        end
        function set.IncludeFiles(h,name)
            h.IncludeFiles=name;
        end
        function set.Buffers(h,bufferStruct)
            validateattributes(bufferStruct,{'struct'},{});
            fieldNames=fieldnames(bufferStruct);
            for i=1:numel(fieldNames)
                if isfield(h.Buffers,fieldNames{i})
                    h.Buffers.(fieldNames{i})=bufferStruct.(fieldNames{i});
                end
            end
        end
        function out=get.Buffers(h)
            out=h.Buffers;
        end
        function out=getMaxNumberOfBuffers(h)
            out=h.Buffers.Max;
        end
        function set.Channels(h,channelStruct)
            validateattributes(channelStruct,{'struct'},{});
            fieldNames=fieldnames(channelStruct);
            for i=1:numel(fieldNames)
                if isfield(h.Channels,fieldNames{i})
                    h.Channels.(fieldNames{i})=channelStruct.(fieldNames{i});
                end
            end
        end
        function out=get.Channels(h)
            out=h.Channels;
        end
        function out=getMaxNumberOfChannels(h)
            out=h.Channels.Max;
        end
        function set.BufferLength(h,bufferLengthStruct)
            fieldNames=fieldnames(bufferLengthStruct);
            for i=1:numel(fieldNames)
                if isfield(h.BufferLength,fieldNames{i})
                    h.BufferLength.(fieldNames{i})=bufferLengthStruct.(fieldNames{i});
                end
            end
        end
        function out=get.BufferLength(h)
            out=h.Buffers;
        end
        function out=getMaxNumberOfBufferLength(h)
            out=h.BufferLength.Max;
        end
        function set.BufferSize(h,size)
            validateattributes(size,{'numeric'},{'scalar','nonempty'});
            h.BufferSize=size;
        end
        function out=get.BufferSize(h)
            out=h.BufferSize;
        end
        function register(h)
            h.serialize();
        end

        function deserialize(h)
            docObj=h.read(h.DefinitionFileName);

            prodInfoList=docObj.getElementsByTagName('productinfo');
            rootItem=prodInfoList.item(0);

            h.Name=h.getElement(rootItem,'name','char');

            h.Type=codertarget.ipc.IPCTypes(...
            h.getElement(rootItem,'type','numeric'));
            h.addChannelInfo(...
            h.getElement(rootItem,'channels','struct'));
            h.addBufferInfo(...
            h.getElement(rootItem,'buffers','struct'));
            h.addBufferLengthInfo(...
            h.getElement(rootItem,'bufferlength','struct'));
            h.BufferSize=h.getElement(rootItem,'buffersize','numeric');
            h.deserializeBuildConfiguration(rootItem)
            h.IncludeFiles=h.BuildConfigurationInfo.SourceFiles;
            h.SourceFiles=h.BuildConfigurationInfo.IncludeFiles;

        end
    end
    methods(Access='private')
        function serialize(h)
            h.addNewBuildConfiguration();
            docObj=h.createDocument('productinfo');
            docObj.item(0).setAttribute('version','3.0');
            h.setElement(docObj,'name',h.Name());
            h.setElement(docObj,'type',h.Type.toNum());
            h.setElement(docObj,'channels',h.getChannelInfoForSerialize());
            h.setElement(docObj,'buffers',h.getBufferInfoForSerialize());
            h.setElement(docObj,'bufferlength',h.getBufferLengthInfoForSerialize());
            h.setElement(docObj,'buffersize',h.BufferSize());


            for i=1:numel(h.BuildConfigurationInfo)
                bcObj=h.BuildConfigurationInfo(i);
                fileName=codertarget.internal.makeValidFileName(bcObj.Name);
                absoluteFilename=[h.TargetFolder,'/registry/ipc/',fileName,'.xml'];
                bcObj.DefinitionFileName=absoluteFilename;
                bcObj.serialize;
                relativeFileName=['$(TARGET_ROOT)','/registry/ipc/',fileName,'.xml'];
                relativeFileName=codertarget.utils.replacePathSep(relativeFileName);
                h.setElement(docObj,'buildconfigurationinfo',relativeFileName);
            end
            h.write(h.DefinitionFileName,docObj);
        end

        function out=getChannelInfoForSerialize(h)
            out.min=h.Channels.Min;
            out.max=h.Channels.Max;
        end
        function addChannelInfo(h,in)
            h.Channels.Min=str2double(in.min);
            h.Channels.Max=str2double(in.max);
        end
        function out=getBufferInfoForSerialize(h)
            out.min=h.Buffers.Min;
            out.max=h.Buffers.Max;
        end
        function addBufferInfo(h,in)
            h.Buffers.Min=str2double(in.min);
            h.Buffers.Max=str2double(in.max);
        end
        function out=getBufferLengthInfoForSerialize(h)
            out.min=h.BufferLength.Min;
            out.max=h.BufferLength.Max;
        end
        function addBufferLengthInfo(h,in)
            h.BufferLength.Min=str2double(in.min);
            h.BufferLength.Max=str2double(in.max);
        end
        function deserializeBuildConfiguration(h,rootItem)
            bcInfoFiles=h.getElement(rootItem,'buildconfigurationinfo','cell');
            targetFolder=h.TargetFolder;
            for i=1:numel(bcInfoFiles)
                bcFile=strrep(bcInfoFiles{i},'$(TARGET_ROOT)',targetFolder);
                bcObj=codertarget.attributes.BuildConfigurationInfo(bcFile);
                h.addNewBuildConfigurationInfo(bcObj.get);
            end
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
                    allBCs=[allBCs,bcObj];%#ok<AGROW>
                end
            end
        end
        function addNewBuildConfiguration(h)
            if isempty(h.getBuildConfigurationInfo)
                valueToSet.Name=[h.Name,' BuildConfiguration'];
                h.addNewBuildConfigurationInfo(valueToSet);
            end
            bcInfo=h.getBuildConfigurationInfo();
            for i=1:numel(bcInfo)
                if~isempty(h.SourceFiles)
                    bcInfo(i).SourceFiles=h.SourceFiles;
                end
                if~isempty(h.IncludeFiles)
                    bcInfo(i).IncludeFiles=h.IncludeFiles;
                end
            end
        end
    end
end
