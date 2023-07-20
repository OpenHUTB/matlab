classdef FileOffsetTdmsReader<matlab.mixin.Copyable




    methods
        function obj=FileOffsetTdmsReader(location,options,selectedChannelGroup,selectedChannels,readSize)

            import matlab.io.tdms.internal.*
            obj.FileSet=matlab.io.datastore.FileSet(location,...
            IncludeSubfolders=options.IncludeSubfolders,...
            FileExtensions=options.FileExtensions,...
            AlternateFileSystemRoots=options.AlternateFileSystemRoots);
            if utility.isEmptyString(selectedChannelGroup)&&~utility.isEmptyString(selectedChannels)
                error(message("tdms:TDMS:ChannelsWithoutChannelGroupSpecified"));
            end
            obj.CurrentFile=obj.FileSet.nextfile();
            obj.Info=tdmsinfo(obj.CurrentFile.Filename);
            validator.mustBeAChannelGroupOf(selectedChannelGroup,obj.Info.ChannelList);
            validator.mustBeChannelsOf(selectedChannels,selectedChannelGroup,obj.Info.ChannelList);

            obj.SelectedChannelGroup=selectedChannelGroup;
            obj.SelectedChannels=selectedChannels;
            obj.ReadSize=readSize;
            obj.Offset=0;

            obj.MaxReadSize=obj.getMaxReadSize();
        end

        function tf=hasdata(obj)
            tf=(obj.Offset<obj.MaxReadSize)||obj.FileSet.hasNextFile();
        end

        function reset(obj)
            obj.Offset=0;
            obj.FileSet.reset();
            obj.CurrentFile=obj.FileSet.nextfile();
        end

        function[data,info]=read(obj)
            readSize=obj.getActualReadSize();
            data=obj.readData(obj.Offset,readSize);
            info.Filename=obj.CurrentFile.Filename;
            info.FileSize=obj.CurrentFile.FileSize;
            info.Offset=obj.Offset;
            obj.advance(readSize);
        end

    end

    methods(Access=protected)
        function readSize=getActualReadSize(obj)
            readSize=obj.ReadSize;
            if obj.Offset+obj.ReadSize>obj.MaxReadSize
                readSize=obj.MaxReadSize-obj.Offset;
            end
        end
    end

    methods(Access=private)
        function maxReadSize=getMaxReadSize(obj)
            import matlab.io.tdms.internal.*
            if utility.isEmptyString(obj.SelectedChannelGroup)
                maxReadSize=max(obj.Info.ChannelList.NumSamples);
            elseif utility.isEmptyString(obj.SelectedChannels)
                rows=ismember(obj.Info.ChannelList.ChannelGroupName,obj.SelectedChannelGroup);
                maxReadSize=max(obj.Info.ChannelList(rows,:).NumSamples);
            else
                rows=ismember(obj.Info.ChannelList.ChannelName,obj.SelectedChannels)...
                &ismember(obj.Info.ChannelList.ChannelGroupName,obj.SelectedChannelGroup);
                maxReadSize=max(obj.Info.ChannelList(rows,:).NumSamples);
            end
        end

        function C=readData(obj,offset,readSize)
            import matlab.io.tdms.internal.*
            C=wrapper.readData(obj.CurrentFile.Filename,offset,readSize,obj.SelectedChannelGroup,obj.SelectedChannels);
        end

        function advance(obj,readSize)
            obj.Offset=obj.Offset+readSize;
            if obj.Offset>=obj.MaxReadSize&&obj.FileSet.hasNextFile()
                obj.CurrentFile=obj.FileSet.nextfile();
                obj.Offset=0;
            end
        end
    end

    methods(Access=protected)
        function objCopy=copyElement(obj)
            objCopy=copyElement@matlab.mixin.Copyable(obj);
            objCopy.FileSet=copy(obj.FileSet);
            objCopy.SelectedChannelGroup=obj.SelectedChannelGroup;
            objCopy.SelectedChannels=obj.SelectedChannels;
            objCopy.ReadSize=obj.ReadSize;
            objCopy.MaxReadSize=obj.MaxReadSize;
            objCopy.Offset=obj.Offset;
            objCopy.CurrentFile=obj.CurrentFile;
            objCopy.Info=obj.Info;
        end
    end

    properties(Access=protected)
        FileSet matlab.io.datastore.FileSet
        SelectedChannelGroup{matlab.io.tdms.internal.validator.mustBeAChannelGroup}=""
        SelectedChannels{matlab.io.tdms.internal.validator.mustBeChannels}=string.empty
        ReadSize(1,1)uint64
        MaxReadSize(1,1)uint64
        Offset(1,1)uint64
        CurrentFile(1,1)
        Info(1,1)
    end
end