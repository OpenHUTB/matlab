


classdef MATFileSimDatastoreImpl<matlab.io.datastore.datastoreimpl.SimDatastoreImpl

    properties(SetAccess=private,...
        GetAccess=?Simulink.SimulationData.Storage.MatFileDatasetStorage)
        FullAttributes;
    end

    properties(Access=private,Hidden,Constant)

        SignalAttributesTime_=...
        Simulink.SimulationData.Storage.MatFileDatasetStorage.R2TimeAttributes;
    end
    properties(Access=private,Hidden,Transient)
        useDefaultTimeAttributes=true;
    end

    methods

        function this=MATFileSimDatastoreImpl(fileName,...
            fullAttributes,...
            storage_version)



















            this.SimImplProps.StorageVersion_=storage_version;
            this.FullAttributes=fullAttributes;
            this.SimImplProps.FileName_=fileName;
        end

        function resolve(this)

            resolvedFileName=...
            matlab.io.datastore.internal.pathLookup(this.SimImplProps.FileName_);
            assert(length(resolvedFileName)==1,...
            ['SimulationDatastore::SimulationDatastore: invalid file name - ',...
            this.SimImplProps.FileName_]);
            this.SimImplProps.FileName_=resolvedFileName{1};

            isR2File=sigstream_mapi('fileIsR2',this.SimImplProps.FileName_);
            if~isR2File
                Simulink.SimulationData.utError('DatastoreSourceChanged',this.getFileName());
            end


            if isempty(this.SimImplProps.FileSignature_)

                r2=sigstream_mapi('openR2',...
                this.SimImplProps.FileName_,...
                'READ_ONLY');
                oc=onCleanup(@()sigstream_mapi('closeR2',r2));

                this.SimImplProps.FileSignature_=sigstream_mapi('getR2Signature',r2);
                this.parseAttributesForStrct(this.FullAttributes,...
                r2,...
                this.SimImplProps.StorageVersion_);
            end
        end

        function fn=getFileName(this)
            fn=this.SimImplProps.FileName_;
        end

        function nSamples=getNumSamples(this)
            nSamples=this.SimImplProps.NSamples_;
        end

        function data=preview(this,varargin)
            try
                this.resolve();
            catch me
                throwAsCaller(me);
            end

            narginchk(1,2);
            if nargin>1
                validateattributes(varargin{1},{'numeric'},...
                {'integer','positive','scalar'});
                previewSize=varargin{1};
            else
                previewSize=this.NumberSamplesForPreview_;
            end
            if this.SimImplProps.NSamples_>0
                dsr2_copy=this.copy;
                dsr2_copy.reset;

                dsr2_copy.ReadSize=previewSize;
                data=dsr2_copy.read;
            else
                data=[];
            end
        end

        function reset(this)
            try
                this.resolve();
            catch me
                throwAsCaller(me);
            end

            this.SimImplProps.NextSample=uint64(1);
        end

        function tf=hasdata(this)
            try
                this.resolve();
            catch me
                throwAsCaller(me);
            end


            tf=this.SimImplProps.NextSample<=this.SimImplProps.NSamples_;
        end

        function p=progress(this)
            try
                this.resolve();
            catch me
                throwAsCaller(me);
            end



            if this.SimImplProps.NextSample-1<this.SimImplProps.NSamples_
                p=double(this.SimImplProps.NextSample-1)/double(this.SimImplProps.NSamples_);
            else
                p=double(1);
            end
        end

        function fullatt=getFullAttributes(this)
            fullatt=this.FullAttributes;
        end

        function ver=getVersion(this)
            ver=this.Version;
        end

        function props=getSimImplProps(this)
            props=this.SimImplProps;
        end
    end

    methods(Access=private)
        function verifyFileIsValid(this,r2)


            r2sig=sigstream_mapi('getR2Signature',r2);
            if r2sig~=this.SimImplProps.FileSignature_
                Simulink.SimulationData.utError('DatastoreSourceChanged',this.getFileName());
            end
        end

        function parseAttributesForStrct(this,strct,r2,storage_version)

            if~isfield(strct,'ElementType')||...
                isequal(strct.ElementType,'timeseries')
                this.SimImplProps.StrctType_='ts';
                this.FullAttributes=strct;
                if isfield(strct,'IsEmpty')&&strct.IsEmpty
                    this.SimImplProps.EmptyStrct_=true;
                end
                if~this.SimImplProps.EmptyStrct_
                    this.SimImplProps.SignalAttributesData_=strct.SignalAttributes;
                    if isfield(strct,'UserData')
                        this.SimImplProps.UserData_=strct.UserData;
                    end
                end
                this.setVariableContinuity(strct);
            elseif isequal(strct.ElementType,'timetable')
                this.SimImplProps.StrctType_='tt';
                this.FullAttributes=strct;

                if isfield(strct,'IsEmpty')&&strct.IsEmpty
                    this.SimImplProps.EmptyStrct_=true;
                end
                if~this.SimImplProps.EmptyStrct_
                    this.SimImplProps.TimeTableProps_=strct.TableProps;
                    this.setVariableContinuity(strct);
                    this.SimImplProps.UserData_=strct.TableProps.UserData;
                    this.SimImplProps.SignalAttributesData_=strct.SignalAttributes;
                end
            elseif isequal(strct.ElementType,'simulation_datastore')
                if this.SimImplProps.FileSignature_==strct.FileSignature
                    this.parseAttributesForStrct(strct.FullAttributes,r2,storage_version);
                    return;
                else
                    Simulink.SimulationData.utError('DatastoreSourceChanged',this.getFileName());
                end
            else
                Simulink.SimulationData.utError('DatastoreRepresentationNotSupported');
            end
            if this.SimImplProps.EmptyStrct_
                this.SimImplProps.NSamples_=uint64(0);
                return;
            end
            if storage_version==4||storage_version==2||storage_version==3
                if isfield(strct,'CompressedTime')&&~isempty(strct.CompressedTime)
                    if length(strct.CompressedTime)~=3



                        this.SimImplProps.IsTimeCompressed_=false;
                        this.SimImplProps.TimeInMemory_=strct.CompressedTime;
                        this.SimImplProps.NSamples_=uint64(length(this.SimImplProps.TimeInMemory_));
                    else
                        this.SimImplProps.IsTimeCompressed_=true;
                        this.SimImplProps.CompressedTime_=strct.CompressedTime;
                        this.SimImplProps.NSamples_=uint64(this.SimImplProps.CompressedTime_(3));
                    end
                elseif isfield(strct,'TimeR2')&&~isempty(strct.TimeR2)
                    this.SimImplProps.TimeRecordIdx_=strct.TimeR2;
                    this.SimImplProps.NSamples_=uint64(sigstream_mapi('getR2RecordLength',...
                    r2,this.SimImplProps.TimeRecordIdx_));
                elseif isfield(strct,'Time')
                    this.SimImplProps.TimeInMemory_=strct.Time;
                    this.SimImplProps.NSamples_=uint64(length(this.SimImplProps.TimeInMemory_));
                else
                    this.SimImplProps.TimeInMemory_=[];
                    this.SimImplProps.NSamples_=uint64(length(this.SimImplProps.TimeInMemory_));
                end
                if isfield(strct,'TimeAttributes')&&~isempty(strct.TimeAttributes)
                    this.SimImplProps.TimeAttributes=strct.TimeAttributes;
                    this.useDefaultTimeAttributes=false;
                end

                this.SimImplProps.DataSampleSizeInElements_=uint64(prod(this.SimImplProps.SignalAttributesData_.Dimension));



                if isfield(strct,'DataR2')
                    this.SimImplProps.DataRecordIdx_=strct.DataR2;
                    if~isempty(this.SimImplProps.DataRecordIdx_)
                        dataRecLength=uint64(sigstream_mapi('getR2RecordLength',...
                        r2,this.SimImplProps.DataRecordIdx_));
                        assert(isequal(mod(dataRecLength,this.SimImplProps.NSamples_),0),...
                        ['SimulationDatastore::parseAttributesForStrct: ',...
                        'inconsistent number of data samples']);

                        if this.SimImplProps.SignalAttributesData_.Complexity
                            this.SimImplProps.DataSampleSizeInElements_=2*this.SimImplProps.DataSampleSizeInElements_;
                        end
                        if this.SimImplProps.NSamples_>0
                            if isfield(strct.SignalAttributes,'FixedPointParameters')
                                if isfield(strct.SignalAttributes,'ResolvedClassName')
                                    if strcmp(strct.SignalAttributes.ResolvedClassName,'double')&&...
                                        strcmp(strct.SignalAttributes.ClassName,'fixed-point')



                                        this.FullAttributes.ClassName='scaled-double';
                                    end
                                else
                                    one_sample=sigstream_mapi('getR2DataInRange',r2,...
                                    this.SimImplProps.DataRecordIdx_,0,0,this.SimImplProps.SignalAttributesData_);
                                    ResolvedClassName=class(one_sample);
                                    this.SimImplProps.SignalAttributesData_.ResolvedClassName=ResolvedClassName;
                                end
                            end
                        end
                    else
                        this.SimImplProps.DataSampleSizeInElements_=uint64(0);
                    end
                else
                    this.SimImplProps.DataInMemory_=strct.Data;

                    if this.SimImplProps.SignalAttributesData_.Complexity&&isreal(this.SimImplProps.DataInMemory_)
                        this.SimImplProps.DataSampleSizeInElements_=2*this.SimImplProps.DataSampleSizeInElements_;
                    end
                    if isfield(strct.SignalAttributes,'FixedPointParameters')
                        this.SimImplProps.SignalAttributesData_.ResolvedClassName=class(this.SimImplProps.DataInMemory_);
                    end
                    assert(iscolumn(this.SimImplProps.DataInMemory_),...
                    'SimulationDatastore::parseAttributesForStrct: in-memory data should be a column vector');
                    sz=uint64(length(this.SimImplProps.DataInMemory_));
                    nElmsIfNoFatBoy=this.SimImplProps.DataSampleSizeInElements_*this.SimImplProps.NSamples_;

                    assert(isequal(mod(sz,nElmsIfNoFatBoy),0),...
                    'SimulationDatastore::parseAttributesForStrct: in-memory data is of inconsistent dimensions');
                    fiWidthFactor=sz/nElmsIfNoFatBoy;
                    if fiWidthFactor>1
                        this.SimImplProps.DataSampleSizeInElements_=this.SimImplProps.DataSampleSizeInElements_*fiWidthFactor;
                    end
                end
            else

                this.SimImplProps.IsTimeCompressed_=strcmp(strct.Time.RecordStorageKey,...
                'Compressed');

                if this.SimImplProps.IsTimeCompressed_
                    this.SimImplProps.CompressedTime_=strct.Time.Data;
                    this.SimImplProps.NSamples_=uint64(this.SimImplProps.CompressedTime_(3));
                else
                    assert(strcmp(strct.Time.RecordStorageKey,'R2'),...
                    'SimulationDatastore: inconsistent signal time attributes');
                    this.SimImplProps.TimeRecordIdx_=strct.Time.Data;
                    this.SimImplProps.NSamples_=uint64(sigstream_mapi('getR2RecordLength',...
                    r2,this.SimImplProps.TimeRecordIdx_));

                end
                isDataR2=strcmp(strct.Data.RecordStorageKey,'R2');
                assert(isDataR2||strcmp(strct.Data.RecordStorageKey,'Raw'),...
                'SimulationDatastore: inconsistent signal data attributes');
                if isDataR2
                    this.SimImplProps.DataRecordIdx_=strct.Data.Data;
                    this.SimImplProps.DataSampleSizeInElements_=uint64(prod(this.SimImplProps.SignalAttributesData_.Dimension));
                    dataRecLength=uint64(sigstream_mapi('getR2RecordLength',...
                    r2,this.SimImplProps.DataRecordIdx_));
                    assert(isequal(mod(dataRecLength,this.SimImplProps.NSamples_),0),...
                    ['SimulationDatastore::parseAttributesForStrct: ',...
                    'inconsistent number of data samples']);

                    if this.SimImplProps.SignalAttributesData_.Complexity
                        this.SimImplProps.DataSampleSizeInElements_=2*this.SimImplProps.DataSampleSizeInElements_;
                    end

                    if this.SimImplProps.NSamples_>0
                        if isfield(strct.SignalAttributes,'FixedPointParameters')

                            if isfield(strct.SignalAttributes,'ResolvedClassName')&&...
                                strcmp(strct.SignalAttributes.ResolvedClassName,'double')&&...
                                strcmp(strct.SignalAttributes.ClassName,'fixed-point')
                                this.FullAttributes.ClassName='scaled-double';
                            else
                                one_sample=sigstream_mapi('getR2DataInRange',r2,...
                                this.SimImplProps.DataRecordIdx_,0,0,this.SimImplProps.SignalAttributesData_);
                                ResolvedClassName=class(one_sample);
                                this.SimImplProps.SignalAttributesData_.ResolvedClassName=ResolvedClassName;
                            end

                            fiWidthFactor=uint64(ceil(...
                            double(strct.SignalAttributes.FixedPointParameters.WordLength)/...
                            (8*Simulink.SimulationData.Storage.MatFileDatasetStorage....
                            ClassName2sampleSizeInBytes(this.SimImplProps.SignalAttributesData_.ResolvedClassName))...
                            ));
                            if fiWidthFactor>1
                                this.SimImplProps.DataSampleSizeInElements_=...
                                this.SimImplProps.DataSampleSizeInElements_*fiWidthFactor;
                            end
                        end
                    end
                else
                    this.SimImplProps.DataInMemory_=strct.Data.Data;
                    this.SimImplProps.DataSampleSizeInElements_=uint64(prod(this.SimImplProps.SignalAttributesData_.Dimension));
                    if this.SimImplProps.SignalAttributesData_.Complexity&&isreal(this.SimImplProps.DataInMemory_)
                        this.SimImplProps.DataSampleSizeInElements_=2*this.SimImplProps.DataSampleSizeInElements_;
                    end
                    if isfield(strct.SignalAttributes,'FixedPointParameters')
                        this.SimImplProps.SignalAttributesData_.ResolvedClassName=class(this.SimImplProps.DataInMemory_);
                    end
                    sz=uint64(length(this.SimImplProps.DataInMemory_));
                    nElmsIfNoFatBoy=this.SimImplProps.DataSampleSizeInElements_*this.SimImplProps.NSamples_;

                    assert(isequal(mod(sz,nElmsIfNoFatBoy),0),...
                    ['SimulationDatastore::parseAttributesForStrct: ',...
                    'v1 in-memory data is of inconsistent dimensions']);
                    fiWidthFactor=sz/nElmsIfNoFatBoy;
                    if fiWidthFactor>1
                        this.SimImplProps.DataSampleSizeInElements_=this.SimImplProps.DataSampleSizeInElements_*fiWidthFactor;
                    end
                end
            end
        end

        function[retTime,retData]=readDataForOneElement(this,r2,lastSample)









            if(this.SimImplProps.IsTimeCompressed_)
                retTime=this.SimImplProps.CompressedTime_(1)+...
                this.SimImplProps.CompressedTime_(2)*(double(this.SimImplProps.NextSample-1:lastSample-1))';
                if~this.useDefaultTimeAttributes
                    retTime=feval(this.SimImplProps.TimeAttributes.ClassName,retTime);
                end
            else
                if isempty(this.SimImplProps.TimeInMemory_)
                    if this.useDefaultTimeAttributes
                        retTime=sigstream_mapi('getR2DataInRange',r2,...
                        this.SimImplProps.TimeRecordIdx_,this.SimImplProps.NextSample-1,...
                        lastSample-1,this.SignalAttributesTime_);
                    else
                        retTime=sigstream_mapi('getR2DataInRange',r2,...
                        this.SimImplProps.TimeRecordIdx_,this.SimImplProps.NextSample-1,...
                        lastSample-1,this.SimImplProps.TimeAttributes);
                    end
                else
                    retTime=this.SimImplProps.TimeInMemory_(this.SimImplProps.NextSample:lastSample);
                end
            end


            if isempty(this.SimImplProps.DataInMemory_)
                retData=sigstream_mapi('getR2DataInRange',r2,...
                this.SimImplProps.DataRecordIdx_,this.SimImplProps.NextSample-1,...
                lastSample-1,this.SimImplProps.SignalAttributesData_);
            else
                retData=this.SimImplProps.DataInMemory_(...
                1+((this.SimImplProps.NextSample-1)*this.SimImplProps.DataSampleSizeInElements_):...
                lastSample*this.SimImplProps.DataSampleSizeInElements_);
            end
        end

        function setVariableContinuity(this,strct)
            if isfield(strct,'InterpMethod')
                if isequal(strct.InterpMethod,'linear')
                    this.SimImplProps.TimeTableProps_.VariableContinuity={'continuous'};
                else
                    this.SimImplProps.TimeTableProps_.VariableContinuity={'step'};
                end
            end
        end
    end

    methods(Access=protected)
        function[data,info]=readData(this)
            if~this.hasdata

                error(message(...
'MATLAB:datastoreio:splittabledatastore:noMoreData'...
                )...
                );
            end

            lastSample=...
            min(this.SimImplProps.NextSample+uint64(this.ReadSize)-1,this.SimImplProps.NSamples_);

            r2=sigstream_mapi('openR2',this.SimImplProps.FileName_,'READ_ONLY');
            oc=onCleanup(@()sigstream_mapi('closeR2',r2));

            this.verifyFileIsValid(r2);

            [retTime,retData]=this.readDataForOneElement(r2,lastSample);
            nTimeSamples=length(retTime);



            retData=Simulink.SimulationData.Storage.DatasetStorage.prepareDataForOutput(...
            retData,this.SimImplProps.SignalAttributesData_,nTimeSamples);









            if nTimeSamples~=1
                if isvector(retData)
                    retData=retData(:);
                elseif~isscalar(this.SimImplProps.SignalAttributesData_.Dimension)



                    retDataSize=size(retData);
                    dimIdx=1:length(retDataSize);
                    if isa(retData,'half')



                        retData=half(permute(single(retData),circshift(dimIdx,1)));
                    else
                        retData=permute(retData,circshift(dimIdx,1));
                    end
                end
            elseif~isscalar(this.SimImplProps.SignalAttributesData_.Dimension)
                retDataSize=size(retData);
                if retDataSize(1)~=1||...
                    (isfield(this.FullAttributes,'IsFromSim')&&...
                    isequal(this.FullAttributes.IsFromSim,true))
                    retData=reshape(retData,[1;retDataSize(:)].');
                end
            end

            if isequal(this.SimImplProps.StrctType_,'ts')
                data=Simulink.SimulationData.Storage.DatasetStorage.packTimeAndDataIntoTimetable(...
                retTime,retData,[]);
                data.Properties.VariableContinuity=...
                this.SimImplProps.TimeTableProps_.VariableContinuity;
            else




                isWide=isequal(numel(this.SimImplProps.SignalAttributesData_.Dimension),1)&&...
                this.SimImplProps.SignalAttributesData_.Dimension>1;
                if isWide&&isempty(this.SimImplProps.TimeTableProps_.UserData)&&...
                    (isfield(this.FullAttributes,'IsFromSim')&&...
                    isequal(this.FullAttributes.IsFromSim,true))
                    this.SimImplProps.TimeTableProps_.UserData.AppData.IsSimulinkWideSignal=true;
                end

                data=Simulink.SimulationData.Storage.DatasetStorage.packTimeAndDataIntoTimetable(...
                retTime,retData,this.SimImplProps.TimeTableProps_);
            end

            info.FileName=this.getFileName();

            if~isempty(this.SimImplProps.UserData_)&&isequal(this.SimImplProps.StrctType_,'ts')

                data.Properties.UserData=this.SimImplProps.UserData_;
            end
            this.SimImplProps.NextSample=lastSample+1;
        end

        function data=readAllData(this)
            try
                this.resolve();
            catch me
                throwAsCaller(me);
            end
            dsr2_copy=this.copy;
            dsr2_copy.reset;
            if dsr2_copy.SimImplProps.NSamples_>0
                dsr2_copy.ReadSize=dsr2_copy.SimImplProps.NSamples_;
            else
                dsr2_copy.ReadSize=1;
            end
            data=dsr2_copy.read;
        end
    end


    properties(GetAccess=public,SetAccess=private,Hidden,Transient)










        SimImplProps=struct(...
        'IsTimeCompressed_',false,...
        'CompressedTime_',[],...
        'DataInMemory_',[],...
        'TimeInMemory_',[],...
        'DataSampleSizeInElements_',uint64(0),...
        'DataRecordIdx_',[],...
        'TimeRecordIdx_',[],...
        'UserData_',[],...
        'FileName_',[],...
        'FileSignature_',[],...
        'SignalAttributesData_',[],...
        'NextSample',uint64(1),...
        'NSamples_',uint64(0),...
        'StorageVersion_',0,...
        'StrctType_','ts',...
        'EmptyStrct_',false,...
        'TimeTableProps_',[]);
    end

end




