classdef socFileReader<handle&matlab.mixin.CustomDisplay
























































    properties
        Description char
        HardwareBoard char
        Tags cell
    end

    properties(Dependent,SetAccess=private)
        Filename char
        Sources cell
    end

    properties(Access=private,Constant)
        PARAM_MATCH_LIST={'Pin','DataType','DataSize',...
        'DataLength','DataByteLength','TypeByteSize','DataLength',...
        'SampleTime','SamplesPerFrame','DataFile','SampleRate',...
        'SamplesPerFrame','NumberOfChannels','RecordedSampleTime',...
        'NumberOfDataPoints','QueueDuration','DataFile','SelectSourceDlg','OutputDataType'}
    end

    properties(Hidden)
Reader
DataType
    end

    properties(GetAccess=public,SetAccess=private,Transient=true)
Date
    end

    properties(Access=private,Transient=true)
        ResolvedFilename_=''
        UncompressLocation_=''
Info_
        LocMap_=containers.Map
    end

    properties(Constant,Hidden)
        Version='2.0';
    end

    methods
        function obj=socFileReader(fileName)
            if nargin<1
                return;
            end
            fileName=convertStringsToChars(fileName);

            obj.ResolvedFilename_=ioplayback.util.resolveFile(fileName,'.tgz');
            dirInfo=dir(obj.ResolvedFilename_);




            if isKey(obj.LocMap_,obj.ResolvedFilename_)
                fileInfo=obj.LocMap_(obj.ResolvedFilename_);
                if(fileInfo.Dir.datenum==dirInfo.datenum)&&...
                    (fileInfo.Dir.bytes==dirInfo.bytes)
                    try
                        obj.UncompressLocation_=ioplayback.util.resolveDirectory(...
                        fileInfo.UncompressLocation);
                    catch
                        remove(obj.LocMap_,obj.ResolvedFilename_);
                        uncompressDataset(obj);
                    end
                else
                    remove(obj.LocMap_,obj.ResolvedFilename_);
                    uncompressDataset(obj);
                end
            else
                uncompressDataset(obj);
            end


            infoFile=fullfile(obj.UncompressLocation_,'dataset.mat');
            obj.Info_=obj.loadInfo(infoFile);
            fileInfo=createFileInfo(obj.ResolvedFilename_,obj.UncompressLocation_);
            obj.LocMap_(obj.ResolvedFilename_)=fileInfo;


            obj.HardwareBoard=obj.Info_.Hardware;
            obj.Description=obj.Info_.Description;
            obj.Tags=obj.Info_.Tags;
            obj.Date=obj.Info_.Date;
        end

        function ret=get.Sources(obj)
            ret={};
            if~isempty(obj.Info_)&&isfield(obj.Info_,'Source')
                for k=1:numel(obj.Info_.Source)
                    ret{end+1}=obj.Info_.Source{k}.SourceName;%#ok<AGROW>
                end
            end
        end

        function ret=get.Filename(obj)
            ret=obj.ResolvedFilename_;
        end

        function ts=getData(obj,sourceName)
            if nargin==2
                sourceName=convertStringsToChars(sourceName);
            end
            dSrc=getDataSource(obj,sourceName);

            if isequal(dSrc.params.FileFormat,'wave')||isequal(sourceName,'plughw:1,0')||isfield(dSrc.params,'SampleRate')
                dataFile=getDataFile(obj,sourceName);
                [y,fs]=audioread(dataFile{2},[1,inf],'native');
                ys=size(y,1);
                te=ys/fs;
                ts=timeseries(y,linspace(0,te,ys));
            else
                dataFile=getDataFile(obj,sourceName);
                if dSrc.params.DataLen==-1
                    variableSizeData=1;
                else
                    variableSizeData=0;
                end
                obj.Reader=ioplayback.util.MultiPortReader('Filename',dataFile,...
                'SignalInfo',dSrc.params.HWSignalInfo,...
                'HWSignalInfo',dSrc.params.HWSignalInfo,...
                'HdrSize',dSrc.HdrSize,...
                'DataLen',dSrc.params.DataLen,...
                'PayloadSizeFieldLen',dSrc.params.PayloadSizeFieldLen);
                setup(obj.Reader,1);
                if variableSizeData
                    tStamps=obj.Reader.SamplesCollected;
                    ts=timeseries(dSrc.SourceName);
                    dt=zeros([dSrc.params.DataSize,1],dSrc.params.DataType);
                    for i=1:tStamps
                        tstamp=readTimestamp(obj.Reader);
                        data=step(obj.Reader,1);
                        dt(1:length(data))=data;
                        dt(length(data)+1:end)=nan;
                        ts=addsample(ts,'Data',dt,'Time',tstamp);
                    end
                else
                    data=[];
                    tseries=[];
                    prevTstamp=0;
                    tStamps=obj.Reader.SamplesCollected;
                    for i=1:tStamps
                        tStamp=readTimestamp(obj.Reader);
                        samples=step(obj.Reader,1);
                        tseries=[tseries;linspace(prevTstamp,tStamp,dSrc.params.SamplesPerFrame)'];%#ok<AGROW>
                        data=[data;samples];%#ok<AGROW>
                        prevTstamp=tStamp;
                    end
                    ts=timeseries(data,tseries);
                end
            end
        end
    end

    methods(Hidden)

        function ret=isDataSourcePresent(obj,sourceName)
            [~,ret]=ismember(sourceName,obj.Sources);
        end

        function source=getDataSource(obj,sourceName)


            if nargin==2
                sourceName=convertStringsToChars(sourceName);
            end
            validateattributes(sourceName,{'char'},{'nonempty','row'},'','sourceName');
            allSourceNames=getAllSourceNames(obj);
            sourceName=validatestring(sourceName,allSourceNames);



            source=obj.Info_.Source{ismember(allSourceNames,sourceName)};
            if isstruct(source)
                if isequal(source.SourceType,'ioplayback.SinkSystem')
                    source.SendSimulationInputTo='Data file';
                else
                    source.SimulationOutput='From recorded file';
                end
                source.DatasetName=obj.Filename;
            end
        end

        function ret=getDataFile(obj,sourceName)

            if nargin==2
                sourceName=convertStringsToChars(sourceName);
            end
            allSourceNames=getAllSourceNames(obj);
            sourceName=validatestring(sourceName,allSourceNames);

            ret={'',''};
            for k=1:numel(obj.Info_.Source)
                if isequal(sourceName,obj.Info_.Source{k}.SourceName)
                    if exist(obj.Info_.Source{k}.DataFile{1},'file')
                        ret=obj.Info_.Source{k}.DataFile;
                    else
                        ret{1}=fullfile(obj.UncompressLocation_,obj.Info_.Source{k}.DataFile{1});
                        ret{2}=fullfile(obj.UncompressLocation_,obj.Info_.Source{k}.DataFile{2});
                    end
                    break;
                end
            end
        end

    end

    methods(Access=protected)
        function allSourceNames=getAllSourceNames(obj)
            allSourceNames={};
            for k=1:numel(obj.Info_.Source)
                allSourceNames{k}=obj.Info_.Source{k}.SourceName;%#ok<AGROW>
            end
        end

        function uncompressDataset(obj)
            obj.UncompressLocation_=tempname;
            try
                untar(obj.ResolvedFilename_,obj.UncompressLocation_);
            catch
                error(message('ioplayback:utils:DatasetOpen'));
            end
        end

        function s=getFooter(obj)
            mc=metaclass(obj);
            s=sprintf('\n  <a href="matlab: methods(''%s'')">Methods</a>, ',mc.Name);
            s=[s,sprintf('<a href="matlab: superclasses(''%s'')">Superclasses</a>\n',mc.Name)];
        end
    end

    methods(Access=private,Static)
        function info=loadInfo(infoFile)
            try
                data=load(infoFile);
                info=data.info;
            catch
                error(message('ioplayback:utils:CorruptedDataset'));
            end
        end
    end
end


function info=createFileInfo(fileName,uncompressLocation)
    info.Dir=dir(fileName);
    info.UncompressLocation=uncompressLocation;
end

