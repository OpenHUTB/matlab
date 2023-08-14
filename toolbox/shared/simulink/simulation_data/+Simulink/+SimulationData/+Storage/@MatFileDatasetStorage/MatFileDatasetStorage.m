



classdef MatFileDatasetStorage<Simulink.SimulationData.Storage.DatasetStorage


    properties(Access=protected,Constant,Transient)
        CurrentVersion_=4;
    end


    properties(Access=protected)


        Version_=Simulink.SimulationData.Storage.MatFileDatasetStorage.CurrentVersion_;






        Elements_={};
        FileName_='';
    end


    properties(Access=public,Hidden,Constant=true)
        R2TimeAttributes=...
        struct(...
        'ClassName','double',...
        'Dimension',uint32(1),...
        'Complexity',logical(false)...
        );
        R2VarDimsAttributes=...
        struct(...
        'ClassName','uint64',...
        'Dimension',uint32(1),...
        'Complexity',false);
    end


    methods
        function nelem=numElements(this)
            if length(this)~=1
                Simulink.SimulationData.utError('InvalidDatasetArray');
            end
            nelem=length(this.Elements_);
        end


        function meta=getMetaData(this,idx,prop)

            if isempty(this.Elements_)
                Simulink.SimulationData.utError('InvalidDatasetGetIndexEmpty');
            end

            this.checkIdxRange(...
            idx,...
            this.numElements(),...
'InvalidDatasetGetIndex'...
            );

            meta=this.Elements_{idx}.(prop);
        end


        function element=getElements(this,idx)



            if isempty(this.Elements_)
                Simulink.SimulationData.utError('InvalidDatasetGetIndexEmpty');
            end

            this.checkIdxRange(idx,this.numElements(),'InvalidDatasetGetIndex');

            r2=sigstream_mapi('openR2',this.FileName_,'READ_ONLY');
            oc=onCleanup(@()sigstream_mapi('closeR2',r2));
            if isscalar(idx)
                if isstruct(this.Elements_{idx})
                    element=Simulink.SimulationData.Storage....
                    DatasetStorage....
                    constructMcosElementFromStructStorage(...
                    this,...
                    this.Elements_{idx},...
                    r2,...
                    this.Version_...
                    );
                else


                    element=this.Elements_{idx};
                    if(this.ReturnAsDatastore&&...
                        ~isa(element,'matlab.io.datastore.SimulationDatastore'))
                        Simulink.SimulationData.utError(...
                        'DatastoreRepresentationNotSupportedForDataType');
                    end
                end
            else
                element=this.Elements_(idx);
                structIdx=find(cellfun(@isstruct,element));
                for ii=1:length(structIdx)
                    eidx=structIdx(ii);
                    element{eidx}=Simulink.SimulationData.Storage.DatasetStorage....
                    ConstructMcosElementFromStructStorage(this,...
                    element{eidx},...
                    r2,...
                    this.Version_);
                end
            end

        end


        function this=setElements(this,idx,element)

            this.checkIdxRange(idx,this.numElements(),'DatasetSetInvalidIdx');
            if isscalar(idx)
                this.Elements_{idx}=element;
            else
                this.Elements_(idx)=element;
            end
        end


        function this=addElements(this,idx,element)

            this.checkIdxRange(idx,this.numElements()+1,'DatasetInsertInvalidIdx');
            if~isscalar(idx)
                Simulink.SimulationData.utError('InvalidDatasetArray');
            end

            this.Elements_=...
            [...
            this.Elements_(1:idx-1),...
            cell(1,length(element)),...
            this.Elements_(idx:end)...
            ];
            try
                this=this.setElements(idx:idx+length(element)-1,element);
            catch me
                throwAsCaller(me);
            end

        end


        function this=removeElements(this,idx)

            this.checkIdxRange(idx,this.numElements(),'DatasetRemoveInvalidIdx');

            this.Elements_(idx)=[];
        end

        this=sortElements(this);

    end


    methods(Hidden)


        function[obj,vData]=constructMcosLeafFromStructStorage(this,strct,varargin)










            if this.ReturnAsDatastore
                obj=this.getElementAsDatastore(strct);
            elseif isfield(strct,'ElementType')
                switch strct.ElementType
                case 'timeseries'
                    obj=this.constructMcosTimeseriesFromStructStorage(...
                    strct,...
                    varargin{:}...
                    );
                case 'timetable'
                    obj=this.constructMcosTimetableFromStructStorage(...
                    strct,...
                    varargin{:}...
                    );
                case 'simulation_datastore'
                    obj=this....
                    constructMcosSimulationDatastoreFromStructStorage(...
                    strct);
                otherwise


                    assert(false,...
                    'MATFileDatasetStorage::constructMcosLeafFromStructStorage Invalid ElementType specified for creation of leaf element from struct');
                end
            else

                obj=this.constructMcosTimeseriesFromStructStorage(...
                strct,...
                varargin{:}...
                );
            end
            vData=Simulink.SimulationData.VisualizationMetadata();
            if isfield(strct,'SampleTime')&&~isempty(strct.SampleTime)
                vData.SampleTime=strct.SampleTime;
            end
            if isfield(strct,'AliasName')&&~isempty(strct.AliasName)
                vData.AliasTypeName=strct.AliasName;
            end

        end


        function fileName=getFileName(this)
            fileName=this.FileName_;
        end


        function version=getVersion(this)
            version=this.Version_;
        end


        function strct=saveobj(this)
            strct.Version=this.Version_;
            strct.Elements=this.Elements_;
            strct.FileName=...
            char([65519,65279,102,105,108,101,110,97,109,101,65279,65519]);
        end


        function elements=utGetElements(this)
            elements=this.Elements_;
        end


        function this=utSetElements(this,elements)



            if isrow(elements)
                this.Elements_=elements;
            else
                this.Elements_=elements';
            end
        end


        function this=utfillfromstruct(this,datasetStruct)


            if~isempty(datasetStruct)
                assert(this.numElements==0);
                this.FileName_=datasetStruct.FileName;
                this=utSetElements(this,datasetStruct.Elements);
            else
                this=[];
            end
        end

        function this=convertTStoTTatLeaf(this)
            for idx=1:numel(this.Elements_)
                this.Elements_{idx}.Values=...
                locConvertTStoTTatLeafRecursion(this.Elements_{idx}.Values);

            end
        end

        function dst=getElementAsDatastore(this,strct,varargin)
            if~isfield(strct,'ElementType')

                strct.ElementType='timeseries';
            end
            if isequal(strct.ElementType,'timeseries')||...
                isequal(strct.ElementType,'timetable')
                dst=matlab.io.datastore.SimulationDatastore.createForMATFile(...
                this.FileName_,...
                strct,...
                this.Version_...
                );
            elseif isequal(strct.ElementType,'simulation_datastore')

                dst=this....
                constructMcosSimulationDatastoreFromStructStorage(strct);
            else
                Simulink.SimulationData.utError('DatastoreRepresentationNotSupported');
            end
        end

        function[values,names,propNames,blockPaths]=utGetMetadataForDisplay(this)
            n=numElements(this);
            values=cell(n,1);
            names=cell(n,1);
            propNames=cell(n,1);
            blockPaths=cell(n,1);

            if n>0
                if isempty(this.Elements_)
                    Simulink.SimulationData.utError('InvalidDatasetGetIndexEmpty');
                end

                for idx=1:n
                    [values{idx},names{idx},propNames{idx},blockPaths{idx}]=...
                    utGetMetadataFromElement(this,this.Elements_{idx});
                end
            end
        end


        function[value,name,propName,blockPath]=utGetMetadataFromElement(this,elm)
            if isfield(elm,'ElementType')
                elementType=elm.ElementType;
            else
                elementType='timeseries';
            end
            switch elementType
            case 'timeseries'
                name=elm.Name;
                blockPath='';
                propName='';
                value='timeseries';
            case 'transparent_element'
                name=elm.Name;
                blockPath='';
                propName='';
                if isfield(elm.Values,'LeafMarker')&&...
                    isequal(elm.Values.LeafMarker,this.LeafMarkerValue)
                    [value,~,~,~]=...
                    utGetMetadataFromElement(this,elm.Values);
                else
                    value=strsplit(class(elm.Values),'.');
                    value=value{end};
                end
            case 'signal'
                name=elm.Name;
                blockPath=strjoin(elm.BlockPath,'|');
                propName=elm.PropagatedName;
                value='Signal';
            case 'param'
                name=elm.Name;
                blockPath=strjoin(elm.BlockPath,'|');
                propName='';
                value='Parameter';
            case{'state','sfstate'}
                name=elm.Name;
                blockPath=strjoin(elm.BlockPath,'|');
                propName='';
                value='State';
            case 'dsm'
                name=elm.Name;
                blockPath=strjoin(elm.BlockPath,'|');
                propName='';
                value='DataStoreMemory';
            case 'sfdata'
                name=elm.Name;
                blockPath=strjoin(elm.BlockPath,'|');
                propName='';
                value='Data';
            case 'simulation_datastore'
                value='SimulationDatastore';
                name='';
                blockPath='';
                propName='';
            case 'timetable'
                value='timetable';
                name='';
                blockPath='';
                propName='';
            case 'dataset'
                value='Dataset';
                name=elm.Name;
                blockPath='';
                propName='';
            case 'assessment'
                name=elm.Name;
                blockPath=strjoin(elm.BlockPath,'|');
                propName='';
                value='Assessment';
            otherwise
                error(['ElementType ',elementType,' not handled.']);
            end
        end

    end


    methods(Static,Hidden=true)


        function obj=constructMcosTimeseriesFromStructStorage(...
            strct,...
varargin...
            )



            if isa(strct,'timeseries')
                obj=strct;
                return
            end

            assert(length(varargin)==2);
            r2=varargin{1};
            version=varargin{2};

            if version==1
                isCompressedTime=...
                strcmp(strct.Time.RecordStorageKey,'Compressed');
                if isCompressedTime
                    starttime=strct.Time.Data(1);
                    increment=strct.Time.Data(2);
                    len=strct.Time.Data(3);
                    nSamples=len;
                else
                    time=locConstructTimeOrDataFromStructStorage(...
                    r2,...
                    strct.Time,...
                    Simulink.SimulationData.Storage....
                    MatFileDatasetStorage.R2TimeAttributes...
                    );
                    nSamples=length(time);
                end
                data=locConstructTimeOrDataFromStructStorage(...
                r2,...
                strct.Data,...
                strct.SignalAttributes...
                );
            elseif version==2||version==3||version==4
                if isfield(strct,'IsEmpty')&&strct.IsEmpty
                    obj=timeseries.empty;
                    return
                end
                isCompressedTime=isfield(strct,'CompressedTime')&&~isempty(strct.CompressedTime);


                if isCompressedTime
                    if length(strct.CompressedTime)~=3
                        isCompressedTime=false;
                        time=strct.CompressedTime;
                        nSamples=length(time);
                    else
                        starttime=strct.CompressedTime(1);
                        increment=strct.CompressedTime(2);
                        len=strct.CompressedTime(3);
                        nSamples=len;
                    end
                else
                    isR2Time=isfield(strct,'TimeR2')&&~isempty(strct.TimeR2);
                    if isR2Time
                        if~isfield(strct,'TimeAttributes')||isempty(strct.TimeAttributes)
                            time=sigstream_mapi(...
                            'getR2Data',...
                            r2,...
                            strct.TimeR2,...
                            Simulink.SimulationData.Storage....
                            MatFileDatasetStorage.R2TimeAttributes...
                            );
                        else
                            time=sigstream_mapi(...
                            'getR2Data',...
                            r2,...
                            strct.TimeR2,...
                            Simulink.SimulationData.Storage....
                            strct.TimeAttributes...
                            );
                        end
                    elseif isfield(strct,'Time')
                        time=strct.Time;
                    else
                        time=[];
                    end
                    nSamples=length(time);
                end
                isR2Data=isfield(strct,'DataR2');
                if isR2Data
                    if isempty(strct.DataR2)
                        if strcmpi(strct.SignalAttributes.ClassName,'fixed-point')

                            data=[];
                        elseif Simulink.SimulationData.Storage.DatasetStorage.isBuiltinType(strct.SignalAttributes.ResolvedClassName)
                            data=zeros(0,1,strct.SignalAttributes.ResolvedClassName);
                        elseif Simulink.SimulationData.Storage.DatasetStorage.isBuiltinType(strct.SignalAttributes.ClassName)
                            data=zeros(0,1,strct.SignalAttributes.ClassName);
                        else
                            data=[];
                        end
                    else
                        data=locVerifyMATandLoadData(r2,strct,nSamples);
                    end
                else
                    data=strct.Data;
                end
            end
            data_reshape=Simulink.SimulationData.Storage.DatasetStorage....
            prepareDataForOutput(...
            data,...
            strct.SignalAttributes,...
nSamples...
            );

            if isCompressedTime
                obj=...
                timeseries.utcreateuniformwithoutcheck(...
                data_reshape,...
                len,...
                starttime,...
                increment,...
                strct.Interp3d,...
                strct.InterpMethod...
                );
            else
                obj=timeseries.utcreatewithoutcheck(...
                data_reshape,...
                time,...
                strct.Interp3d,...
                strct.DuplicateTimes,...
                strct.InterpMethod...
                );
            end
            obj.Name=strct.Name;
            if version==1||version==2||version==3
                dataUnits=strct.Units;
            else
                assert(...
                version==4,...
                [...
                'MatFileDatasetStorage::',...
                'constructMcosTimeseriesFromStructStorage: unexpected ',...
'value for version'...
                ]...
                );
                dataUnits=...
                Simulink.SimulationData.Storage.DatasetStorage....
                constructMcosUnitsFromStructStorage(strct.DataUnits);
                obj.TimeInfo.Units=...
                Simulink.SimulationData.Storage.DatasetStorage....
                constructMcosUnitsFromStructStorage(strct.TimeUnits);
            end
            obj.DataInfo.Units=dataUnits;
            if isfield(strct,'UserData')
                obj.UserData=strct.UserData;
            end
        end


        function tt=constructVardimsTimetableFromStructStorage(strct,varargin)



            r2=varargin{1};
            rawVarDims=sigstream_mapi(...
            'getR2Data',...
            r2,...
            strct.VarDimsR2,...
            Simulink.SimulationData.Storage.MatFileDatasetStorage.R2VarDimsAttributes);
            numTimePts=numel(rawVarDims)/strct.NumVarDims;
            varDims=zeros([numTimePts,strct.NumVarDims],'uint32');
            curIdx=1;
            for tIdx=1:numTimePts
                for eIdx=1:strct.NumVarDims
                    varDims(tIdx,eIdx)=rawVarDims(curIdx);
                    curIdx=curIdx+1;
                end
            end


            isCompressedTime=isfield(strct,'CompressedTime')&&~isempty(strct.CompressedTime);
            if isCompressedTime
                if length(strct.CompressedTime)~=3
                    time=strct.CompressedTime;
                else
                    starttime=strct.CompressedTime(1);
                    increment=strct.CompressedTime(2);
                    time=starttime+increment*(0:1:numTimePts-1)';
                end
            else
                isR2Time=isfield(strct,'TimeR2')&&~isempty(strct.TimeR2);
                if isR2Time
                    time=sigstream_mapi(...
                    'getR2Data',...
                    r2,...
                    strct.TimeR2,...
                    Simulink.SimulationData.Storage....
                    MatFileDatasetStorage.R2TimeAttributes...
                    );
                elseif isfield(strct,'Time')
                    time=strct.Time;
                else
                    time=[];
                end
            end


            strct.SignalAttributes.Dimension=uint32(1);
            rawData=locVerifyMATandLoadData(r2,strct,numTimePts);
            data=cell(numTimePts,1);
            complexityFactor=strct.SignalAttributes.Complexity+1;

            if isfield(strct,'fiSampleSizeFactor')&&~isempty(strct.fiSampleSizeFactor)

                assert(isfield(strct,'isStreamingToV73')&&~isempty(strct.isStreamingToV73));

                fiSampleSizeFactor=strct.fiSampleSizeFactor;
            else
                recordSampleSize=uint64(sigstream_mapi('getR2RecordSampleSize',...
                r2,...
                strct.DataR2));
                fiSampleSizeFactor=(uint64(recordSampleSize)>8)+1;
            end


            curIdx=1;
            for idx=1:numTimePts


                dim=varDims(idx,:)';
                if length(dim)==1
                    dim(2,:)=1;
                end

                strct.SignalAttributes.Dimension=dim;
                numEl=prod(strct.SignalAttributes.Dimension)*complexityFactor*fiSampleSizeFactor;

                curData=rawData(curIdx:curIdx+numEl-1);
                data{idx}=Simulink.SimulationData.Storage.DatasetStorage.prepareDataForOutput(...
                curData,...
                strct.SignalAttributes,...
                1);

                curIdx=curIdx+numEl;
            end


            if isfield(strct,'TableProps')
                tt_props=strct.TableProps;
                if isfield(strct.TableProps,'VariableContinuity')
                    tt_props.VariableContinuity=strct.TableProps.VariableContinuity;
                elseif isfield(strct,'InterpMethod')
                    if isequal(strct.InterpMethod,'linear')
                        tt_props.VariableContinuity={'continuous'};
                    else
                        tt_props.VariableContinuity={'step'};
                    end
                end
            else
                tt_props=[];
            end


            tt=Simulink.SimulationData.Storage.DatasetStorage.packTimeAndDataIntoTimetable(...
            time,data,tt_props);
            if isempty(tt.Properties.VariableUnits)
                tt.Properties.VariableUnits={''};
            end
        end


        function tt=constructMcosTimetableFromStructStorage(strct,varargin)
            assert(~isa(strct,'timetable'),...
            'MatFileDatasetStorage::constructMcosTimetableFromStructStorage: struct representation is invalid');


            if isfield(strct,'VarDimsR2')&&~isempty(strct.VarDimsR2)
                tt=Simulink.SimulationData.Storage.MatFileDatasetStorage.constructVardimsTimetableFromStructStorage(...
                strct,varargin{:});
                return
            end

            if isfield(strct,'IsEmpty')&&strct.IsEmpty
                tt=timetable.empty;
                return
            end

            r2=varargin{1};
            version=varargin{2};
            assert(version==4,...
            'MatFileDatasetStorage::constructMcosTimetableFromStructStorage: timetable may be reconstructed only on current version');

            isCompressedTime=isfield(strct,'CompressedTime')&&~isempty(strct.CompressedTime);
            if isCompressedTime
                if length(strct.CompressedTime)~=3
                    time=strct.CompressedTime;
                    nSamples=length(time);
                else
                    starttime=strct.CompressedTime(1);
                    increment=strct.CompressedTime(2);
                    len=strct.CompressedTime(3);
                    nSamples=len;
                    time=starttime+...
                    increment*(0:1:len-1)';
                end
            else
                isR2Time=isfield(strct,'TimeR2')&&~isempty(strct.TimeR2);
                if isR2Time
                    time=sigstream_mapi(...
                    'getR2Data',...
                    r2,...
                    strct.TimeR2,...
                    Simulink.SimulationData.Storage....
                    MatFileDatasetStorage.R2TimeAttributes...
                    );
                elseif isfield(strct,'Time')
                    time=strct.Time;
                else
                    time=[];
                end
                nSamples=length(time);
            end

            isR2Data=isfield(strct,'DataR2');
            if isR2Data
                data=locVerifyMATandLoadData(r2,strct,nSamples);
            else
                data=strct.Data;
            end

            data_reshape=Simulink.SimulationData.Storage.DatasetStorage....
            prepareDataForOutput(...
            data,...
            strct.SignalAttributes,...
nSamples...
            );

            datasize=size(data_reshape);
            if nSamples~=1


                isTimeFirst=length(datasize)<=2;
            else


                if length(datasize)==2&&datasize(1)==1


                    if isfield(strct,'Interp3d')



                        isTimeFirst=~strct.Interp3d;
                    else

                        isTimeFirst=true;
                    end
                else
                    isTimeFirst=false;
                end
            end

            if~isTimeFirst&&nSamples~=1

                if~isvector(data_reshape)
                    retDataSize=size(data_reshape);
                    dimIdx=1:length(retDataSize);
                    if isa(data_reshape,'half')



                        data=half(permute(single(data_reshape),circshift(dimIdx,1)));
                    else
                        data=permute(data_reshape,circshift(dimIdx,1));
                    end
                else
                    data=data_reshape(:);
                end
            else

                data=data_reshape;

                if~isTimeFirst&&isequal(numel(strct.SignalAttributes.Dimension),2)
                    data=reshape(data,[1;strct.SignalAttributes.Dimension(:)]');
                end
            end

            if isfield(strct,'TableProps')
                tt_props=strct.TableProps;
                if isfield(strct.TableProps,'VariableContinuity')


                    tt_props.VariableContinuity=strct.TableProps.VariableContinuity;
                elseif isfield(strct,'InterpMethod')


                    if isequal(strct.InterpMethod,'linear')
                        tt_props.VariableContinuity={'continuous'};
                    else
                        tt_props.VariableContinuity={'step'};
                    end
                end
            else
                tt_props=[];
            end





            isWide=isequal(numel(strct.SignalAttributes.Dimension),1)&&...
            strct.SignalAttributes.Dimension>1&&isfield(strct,'Interp3d');
            if isWide&&isempty(tt_props.UserData)&&...
                (isfield(strct,'IsFromSim')&&...
                isequal(strct.IsFromSim,true))
                tt_props.UserData.AppData.IsSimulinkWideSignal=true;
            end

            tt=Simulink.SimulationData.Storage.DatasetStorage.packTimeAndDataIntoTimetable(...
            time,data,tt_props);
        end


        function obj=createFromRamDatasetStorage(ramDatasetStorage,fileName)











            assert(...
            isa(...
            ramDatasetStorage,...
'Simulink.SimulationData.Storage.RamDatasetStorage'...
            )...
            );
            obj=Simulink.SimulationData.Storage.MatFileDatasetStorage;
            obj.FileName_=fileName;
            nElements=ramDatasetStorage.numElements;
            obj.Elements_=cell(1,nElements);
            r2=sigstream_mapi('openR2',obj.FileName_,'READ_WRITE');
            oc=onCleanup(@()sigstream_mapi('closeR2',r2));
            for idx=1:nElements
                ramElement=ramDatasetStorage.getElements(idx);
                obj.Elements_{idx}=...
                locConstructStructStorageFromDatasetElement(...
                r2,...
                ramElement,...
                Simulink.SimulationData.Storage.MatFileDatasetStorage....
R2TimeAttributes...
                );
            end
        end


        function obj=loadobj(strct)
            obj=Simulink.SimulationData.Storage.MatFileDatasetStorage;
            obj.Version_=strct.Version;
            obj.Elements_=strct.Elements;
            obj.FileName_=strct.FileName;

            if obj.Version_>Simulink.SimulationData.Storage.MatFileDatasetStorage.CurrentVersion_
                Simulink.SimulationData.utError('LoadingNewerVersionNotAllowed',...
                'Simulink.SimulationData.Storage.MatFileDatasetStorage');
            end
        end


        function sampleSizeInBytes=ClassName2sampleSizeInBytes(className)


            if strcmp(className,'double')
                sampleSizeInBytes=8;
            elseif strcmp(className,'single')
                sampleSizeInBytes=4;
            elseif strcmp(className,'half')
                sampleSizeInBytes=2;
            elseif strcmp(className,'int8')
                sampleSizeInBytes=1;
            elseif strcmp(className,'uint8')
                sampleSizeInBytes=1;
            elseif strcmp(className,'int16')
                sampleSizeInBytes=2;
            elseif strcmp(className,'uint16')
                sampleSizeInBytes=2;
            elseif strcmp(className,'int32')
                sampleSizeInBytes=4;
            elseif strcmp(className,'uint32')
                sampleSizeInBytes=4;
            elseif strcmp(className,'int64')
                sampleSizeInBytes=8;
            elseif strcmp(className,'uint64')
                sampleSizeInBytes=8;
            elseif strcmp(className,'char')||strcmp(className,'string')
                sampleSizeInBytes=1;
            else
                assert(strcmp(className,'logical'),...
                ['MatFileDatasetStorage::ClassName2sampleSizeInBytes: ',...
                'Non-builtin type']);
                sampleSizeInBytes=1;
            end
        end

    end

end


function result=...
    locConstructTimeOrDataFromStructStorage(r2,strct,signalAttributes)


    if strcmp(strct.RecordStorageKey,'R2')
        recordId=strct.Data;
        result=sigstream_mapi('getR2Data',r2,recordId,signalAttributes);
    else
        assert(strcmp(strct.RecordStorageKey,'Raw'));


        result=strct.Data;
    end
end


function strct=...
    locConstructStructStorageFromDatasetElement(r2,obj,timeAttributes)




    if isa(obj,'timeseries')
        strct=...
        locConstructStructStorageFromTimeseries(r2,obj,timeAttributes);
    elseif isa(obj,'Simulink.SimulationData.Signal')
        strct=locConstructStructStorageFromSignal(r2,obj,timeAttributes);
    elseif isa(obj,'Simulink.SimulationData.Parameter')
        strct=locConstructStructStorageFromParam(r2,obj,timeAttributes);
    elseif isa(obj,'Simulink.SimulationData.State')
        strct=locConstructStructStorageFromState(r2,obj,timeAttributes);
    elseif isa(obj,'Simulink.SimulationData.DataStoreMemory')
        strct=locConstructStructStorageFromDsm(r2,obj,timeAttributes);
    elseif isa(obj,'Stateflow.SimulationData.State')||...
        isa(obj,'Stateflow.SimulationData.Data')||...
        isa(obj,'Stateflow.SimulationData.ChartActivity')
        strct=locConstructStructStorageFromSfElement(r2,obj,timeAttributes);
    elseif isa(obj,'Simulink.SimulationData.TransparentElement')
        strct=locConstructStructStorageFromTransparentElement(...
        r2,...
        obj,...
timeAttributes...
        );
    elseif isa(obj,'timetable')
        strct=...
        locConstructStructStorageFromTimetable(r2,obj,timeAttributes);
    elseif isa(obj,'matlab.io.datastore.SimulationDatastore')
        strct=...
        locConstructStructStorageFromSimulationDatastore(obj);
    elseif isa(obj,'Simulink.SimulationData.Dataset')
        strct=...
        locConstructStructStorageFromNestedDataset(r2,obj,timeAttributes);
    elseif isa(obj,'Simulink.SimulationData.BlockData')

        strct=...
        locConstructStructStorageFromBlockData(r2,obj,timeAttributes);
    else
        strct=...
        locConstructStructStorageFromMcosValues(r2,obj,timeAttributes);
    end
end


function strct=locConstructStructStorageFromDsm(r2,dsm,timeAttributes)
    strct.ElementType='dsm';
    strct.Name=dsm.Name;
    [strct.BlockPath,~]=dsm.BlockPath.getAsCellArray;
    strct.Scope=dsm.Scope;
    strct.DSMWriterBlockPaths=dsm.convertWriterPathsToCell;
    DSMWritersAttributes=...
    Simulink.SimulationData.Storage.DatasetStorage....
    createDSMWritersAttributes;
    DSMWritersLength=length(dsm.DSMWriters);
    strct.DSMWritersR2=...
    locCreateRecord(...
    r2,...
    dsm.DSMWriters',...
    DSMWritersAttributes,...
DSMWritersLength...
    );
    strct.Values=...
    locConstructStructStorageFromMcosValues(...
    r2,...
    dsm.Values,...
timeAttributes...
    );
end


function strct=locConstructStructStorageFromSignal(r2,signal,timeAttributes)
    strct.ElementType='signal';
    strct.Name=signal.Name;
    strct.PropagatedName=signal.PropagatedName;
    [strct.BlockPath,~]=signal.BlockPath.getAsCellArray;
    strct.PortType=signal.PortType;
    strct.PortIndex=signal.PortIndex;
    strct.Values=...
    locConstructStructStorageFromMcosValues(...
    r2,...
    signal.Values,...
timeAttributes...
    );
end


function strct=...
    locConstructStructStorageFromSfElement(r2,sfelement,timeAttributes)

    if isa(sfelement,'Stateflow.SimulationData.State')
        strct.ElementType='sfstate';
    elseif isa(sfelement,'Stateflow.SimulationData.Data')
        strct.ElementType='sfdata';
    else
        assert(isa(sfelement,'Stateflow.SimulationData.ChartActivity'),...
        'MATFileDatasetStorage: expecting Stateflow ChartActivity');
        strct.ElementType='sfchartactivity';
    end
    strct.Name=sfelement.Name;
    [strct.BlockPath,strct.BlockSubPath]=sfelement.BlockPath.getAsCellArray;
    strct.Values=...
    locConstructStructStorageFromMcosValues(...
    r2,...
    sfelement.Values,...
timeAttributes...
    );
end


function strct=locConstructStructStorageFromParam(r2,param,timeAttributes)
    strct.ElementType='param';
    strct.Name=param.Name;
    [strct.BlockPath,~]=param.BlockPath.getAsCellArray;
    strct.Values=...
    locConstructStructStorageFromMcosValues(...
    r2,...
    param.Values,...
timeAttributes...
    );
end


function strct=locConstructStructStorageFromState(r2,state,timeAttributes)
    strct.ElementType='state';
    strct.Name=state.Name;
    [strct.BlockPath,~]=state.BlockPath.getAsCellArray;
    stateType=state.Label;
    if stateType==Simulink.SimulationData.StateType.DSTATE
        strct.StateType='DSTATE';
    else
        assert(stateType==Simulink.SimulationData.StateType.CSTATE);
        strct.StateType='CSTATE';
    end
    strct.Values=...
    locConstructStructStorageFromMcosValues(...
    r2,...
    state.Values,...
timeAttributes...
    );
end
function strct=locConstructStructStorageFromBlockData(r2,obj,timeAttributes)


    strct.Object=obj;

    strct.Object.Values=[];


    strct.Name=obj.Name;
    strct.BlockPath=obj.BlockPath.getAsCellArray;

    strct.ElementType='blockdata';
    strct.Values=...
    locConstructStructStorageFromMcosValues(...
    r2,...
    obj.Values,...
timeAttributes...
    );
end


function strct=...
    locConstructStructStorageFromTimeseries(r2,ts,timeAttributes)
    assert(isa(ts,'timeseries'));
    if isempty(ts)
        strct.LeafMarker=...
        Simulink.SimulationData.Storage.DatasetStorage.LeafMarkerValue;
        strct.ElementType='timeseries';
        strct.IsEmpty=true;
        strct.UserData=[];
    elseif~isscalar(ts)
        dim=size(ts);
        for idx=1:numel(ts)
            if idx==1
                strct=locConstructStructStorageFromTimeseries(...
                r2,...
                ts(idx),...
timeAttributes...
                );
                strct=repmat(strct,dim);
            else
                strct(idx)=locConstructStructStorageFromTimeseries(...
                r2,...
                ts(idx),...
timeAttributes...
                );
            end
        end
    elseif issparse(ts.Data)||issparse(ts.Time)||isstring(ts.Data)||ischar(ts.Data)
        strct=ts;
    else

        strct.LeafMarker=...
        Simulink.SimulationData.Storage.DatasetStorage.LeafMarkerValue;
        strct.ElementType='timeseries';
        strct.IsEmpty=false;
        strct.Name=ts.Name;
        strct.UserData=ts.UserData;
        strct.TimeUnits=...
        Simulink.SimulationData.Storage.DatasetStorage....
        constructStructStorageFromUnits(ts.TimeInfo.Units);
        strct.DataUnits=...
        Simulink.SimulationData.Storage.DatasetStorage....
        constructStructStorageFromUnits(ts.DataInfo.Units);
        nSamples=length(ts.Time);

        if ts.IsTimeFirst&&nSamples~=1



            assert(ismatrix(ts.Data));
            data=ts.Data.';
        else
            data=ts.Data;
        end

        [data,signalAttributes]=locPreprocessData(data,nSamples);
        strct.DataR2=locCreateRecord(r2,data,signalAttributes,nSamples);

        if isempty(ts.Time)
            strct.Time=ts.Time;
            strct.TimeR2=[];
            strct.TimeAttributes=[];
            strct.CompressedTime=[];
        elseif isnan(ts.TimeInfo.Increment)
            if isa(ts.Time,timeAttributes.ClassName)
                strct.TimeR2=...
                locCreateRecord(r2,ts.Time,timeAttributes,nSamples);
                strct.TimeAttributes=[];
            else
                [time,locTimeAttributes]=locPreprocessData(ts.Time,nSamples);
                strct.TimeR2=locCreateRecord(r2,time,locTimeAttributes,nSamples);
                strct.TimeAttributes=locTimeAttributes;
            end
            strct.Time=[];
            strct.CompressedTime=[];
        else
            strct.Time=[];
            strct.TimeR2=[];
            strct.TimeAttributes=[];
            strct.CompressedTime=...
            [ts.TimeInfo.Start,ts.TimeInfo.Increment,nSamples];

        end
        strct.StartDate='';
        strct.Interp3d=ts.DataInfo.InterpretSingleRowDataAs3D;
        strct.DuplicateTimes=ts.TimeInfo.DuplicateTimes;
        strct.InterpMethod=ts.DataInfo.Interpolation.Name;
        strct.SignalAttributes=signalAttributes;
    end
end

function strct=...
    locConstructStructStorageFromTimetable(r2,tt,timeAttributes)
    assert(isa(tt,'timetable'));

    strct.LeafMarker=...
    Simulink.SimulationData.Storage.DatasetStorage.LeafMarkerValue;
    strct.ElementType='timetable';

    if isempty(tt)
        strct.IsEmpty=true;
    else
        strct.IsEmpty=false;



        strct.TableProps.Description=tt.Properties.Description;
        strct.TableProps.UserData=tt.Properties.UserData;
        strct.TableProps.DimensionNames=tt.Properties.DimensionNames;
        strct.TableProps.VariableNames=tt.Properties.VariableNames;
        strct.TableProps.VariableDescriptions=...
        tt.Properties.VariableDescriptions;


        strct.TableProps.VariableUnits=tt.Properties.VariableUnits;
        strct.TableProps.VariableContinuity=tt.Properties.VariableContinuity;

        assert(...
        numel(tt.Properties.VariableNames)==1,...
        [...
'MatFileDatasetStorage::locConstructStructStorageFromTimetable:'...
        ,' only single column timetable is supported with Dataset'...
        ]...
        );

        Data=tt.(tt.Properties.VariableNames{1});
        if~issparse(Data)&&~isstring(Data)&&~ischar(Data)
            nSamples=length(tt.Properties.RowTimes);

            data_size=size(Data);
            if nSamples~=1


                if isa(Data,'half')



                    ts_data=half(permute(single(Data),circshift((1:length(data_size)),-1)));
                else
                    ts_data=permute(Data,circshift((1:length(data_size)),-1));
                end
            else
                ts_data=Data;
            end



            if isa(ts_data,'cell')


                [strct,signalAttributes]=locStreamVardimsDataToR2(strct,r2,ts_data,nSamples);
            else
                [ts_data,signalAttributes]=locPreprocessData(ts_data,nSamples);
                strct.DataR2=locCreateRecord(r2,ts_data,signalAttributes,nSamples);
            end

            strct.SignalAttributes=signalAttributes;
            if isa(tt.Properties.RowTimes,'duration')

                Time=seconds(tt.Properties.RowTimes);

                strct.TableProps.TimeFormat='duration';


                strct.TableProps.TimeUnits='seconds';

            else
                assert(isa(tt.Properties.RowTimes,'datetime'),...
                'Timetable must specify time as duration or datetime');
                strct.TableProps.TimeFormat='datetime';
                Time=datenum(tt.Properties.RowTimes);
            end
            strct.TableProps.TimeDisplayFormat=tt.Properties.RowTimes(1).Format;
            strct.TimeR2=locCreateRecord(r2,Time,timeAttributes,nSamples);
        else


            strct=tt;
        end
    end
end

function strct=...
    locConstructStructStorageFromSimulationDatastore(dst)


    assert(isa(dst,'matlab.io.datastore.SimulationDatastore'),...
    'MatFileDatasetStorage::SimulationDatastore is the only datastore that is supported with SimulationData');

    if isempty(dst)
        strct.LeafMarker=...
        Simulink.SimulationData.Storage.DatasetStorage.LeafMarkerValue;
        strct.ElementType='simulation_datastore';
        strct.IsEmpty=true;
    elseif isscalar(dst)
        strct.LeafMarker=...
        Simulink.SimulationData.Storage.DatasetStorage.LeafMarkerValue;
        strct.ElementType='simulation_datastore';
        strct.IsEmpty=false;
        strct.FileName=dst.FileName;
        strct.FullAttributes=dst.getFullAttributes();
        strct.Version=dst.Version;
        strct.StorageVersion=dst.getSimImplProps.StorageVersion_;
        strct.FileSignature=dst.getSimImplProps.FileSignature_;
    else
        dim=size(dst);
        for idx=1:numel(dst)
            if idx==1
                strct=locConstructStructStorageFromSimulationDatastore(...
                dst(idx)...
                );
                strct=repmat(strct,dim);
            else
                strct(idx)=locConstructStructStorageFromSimulationDatastore(...
                dst(idx)...
                );
            end
        end
    end
end

function strct=locConstructStructStorageFromTransparentElement(...
    r2,...
    el,...
timeAttributes...
    )

    strct.ElementType='transparent_element';
    strct.Name=el.Name;
    strct.Values=...
    locConstructStructStorageFromMcosValues(...
    r2,...
    el.Values,...
timeAttributes...
    );
end


function strct=...
    locConstructStructStorageFromMcosValues(...
    r2,...
    values,...
timeAttributes...
    )

    if isa(values,'timeseries')
        strct=...
        locConstructStructStorageFromTimeseries(r2,values,timeAttributes);
    elseif isa(values,'timetable')
        strct=...
        locConstructStructStorageFromTimetable(r2,values,timeAttributes);
    elseif isa(values,'matlab.io.datastore.SimulationDatastore')
        strct=locConstructStructStorageFromSimulationDatastore(values);
    elseif isstruct(values)
        fields=fieldnames(values);
        dim=[length(fields),size(values)];
        emptyData=cell(dim);
        strct=cell2struct(emptyData,fields,1);
        for idx=1:numel(values)
            for fieldIdx=1:length(fields)
                field=fields{fieldIdx};
                strct(idx).(field)=...
                locConstructStructStorageFromMcosValues(...
                r2,...
                values(idx).(field),...
                timeAttributes);
            end
        end
    elseif iscell(values)
        strct.ForeachDimensions=size(values);
        strct.ForeachElements=cell(numel(values),1);
        strct.SignalType='timetable';



        strct.ForeachNeedsPermuteDims=false;

        for idx=1:numel(values)
            strct.ForeachElements{idx}=...
            locConstructStructStorageFromMcosValues(...
            r2,...
            values{idx},...
            timeAttributes);
        end
    else
        strct=values;
    end







    strct=locRemoveUnneededTimeProps(strct);
end


function strct=locRemoveUnneededTimeProps(strct)
    if isstruct(strct)
        if isfield(strct,'CompressedTime')||isfield(strct,'TimeAttributes')

            if isfield(strct,'CompressedTime')&&locTimeseriesHasAllEmptyTimeProp(strct,'CompressedTime')
                strct=rmfield(strct,'CompressedTime');
            end
            if isfield(strct,'TimeAttributes')&&locTimeseriesHasAllEmptyTimeProp(strct,'TimeAttributes')
                strct=rmfield(strct,'TimeAttributes');
            end
        else

            fnames=fieldnames(strct);
            for idx=1:numel(strct)
                for fidx=1:length(fnames)
                    fname=fnames{fidx};
                    strct(idx).(fname)=locRemoveUnneededTimeProps(strct(idx).(fname));
                end
            end
        end
    end
end


function ret=locTimeseriesHasAllEmptyTimeProp(strct,fname)
    ret=true;
    for idx=1:numel(strct)
        if~isempty(strct(idx).(fname))
            ret=false;
            return
        end
    end
end


function strct=locConstructStructStorageFromNestedDataset(r2,ds,timeAttributes)
    strct.ElementType='dataset';
    strct.Name=ds.Name;
    nElements=ds.numElements;
    storage=ds.getStorage();
    elements=storage.utGetElements();
    switch class(storage)
    case 'Simulink.SimulationData.Storage.MatFileDatasetStorage'
        for idx=1:nElements
            switch elements{idx}.ElementType
            case 'transparent_element'
                el=Simulink.SimulationData.TransparentElement();
                try
                    el.Value=ds{idx};
                    el.Name=ds{idx}.name;
                catch
                    [el.Value,el.Name]=ds.get(idx);
                end
            otherwise
                el=ds{idx};
            end

            strct.Values{idx}=...
            locConstructStructStorageFromDatasetElement(...
            r2,...
            el,...
timeAttributes...
            );
        end
    otherwise
        for idx=1:nElements
            strct.Values{idx}=...
            locConstructStructStorageFromDatasetElement(...
            r2,...
            elements{idx},...
timeAttributes...
            );
        end
    end
end


function fixedPointParameters=locCreateFixedPointParameters(nt)
    fixedPointParameters.isSigned=nt.SignednessBool;
    fixedPointParameters.WordLength=int32(nt.WordLength);
    fixedPointParameters.SlopeAdjustmentFactor=nt.SlopeAdjustmentFactor;
    fixedPointParameters.Exponent=int32(nt.FixedExponent);
    fixedPointParameters.Bias=nt.Bias;
end


function ssb=locSignalAttributes2sampleSizeInBytes(signalAttributes)
    useResolvedClass=false;
    if Simulink.SimulationData.Storage.DatasetStorage....
        isBuiltinType(signalAttributes.ClassName)
        sampleSizeInBytes=Simulink.SimulationData.Storage.MatFileDatasetStorage....
        ClassName2sampleSizeInBytes(signalAttributes.ClassName);
    elseif Simulink.SimulationData.Storage.DatasetStorage....
        isBuiltinType(signalAttributes.ResolvedClassName)
        sampleSizeInBytes=Simulink.SimulationData.Storage.MatFileDatasetStorage....
        ClassName2sampleSizeInBytes(signalAttributes.ResolvedClassName);
        useResolvedClass=true;
    else
        assert(false,...
        ['MatFileDatasetStorage::locSignalAttributes2sampleSizeInBytes: ',...
        'unsupported datatype']);
    end

    if isfield(signalAttributes,'FixedPointParameters')
        wl=double(signalAttributes.FixedPointParameters.WordLength);
        assert(useResolvedClass,...
        ['MatFileDatasetStorage::locSignalAttributes2sampleSizeInBytes',...
        'fixed point data was not cast a built in type']);

        fiWidthFactor=ceil(wl/(8*sampleSizeInBytes));
        if fiWidthFactor>1
            sampleSizeInBytes=sampleSizeInBytes*fiWidthFactor;
        end
    end
    ssb=sampleSizeInBytes*prod(signalAttributes.Dimension);
    if signalAttributes.Complexity
        ssb=ssb*2;
    end
end


function recordId=locCreateRecord(r2,data,signalAttributes,length)

    if isempty(data)
        recordId=[];
    else
        SampleSizeInBytes=locSignalAttributes2sampleSizeInBytes(signalAttributes);
        recordId=...
        sigstream_mapi(...
        'r2CreateRecord',...
        r2,...
        SampleSizeInBytes,...
        length,...
        isequal(signalAttributes.ClassName,'half'),...
data...
        );
    end
end


function[strct,signalAttributes]=locStreamVardimsDataToR2(strct,r2,data,numPts)














    if isempty(data)
        strct.DataR2=[];
        return;
    end























    procData=data{1};

    signalAttributes.Dimension=uint32(1);
    signalAttributes.Complexity=~isreal(procData)&&isnumeric(procData);
    complexityFactor=signalAttributes.Complexity+1;
    fiSampleSizeFactor=1;

    if isa(procData,'embedded.fi')
        if~isscaleddouble(procData)
            signalAttributes.ClassName='fixed-point';
        else
            signalAttributes.ClassName='scaled-double';
        end
        nt=numerictype(procData);
        signalAttributes.FixedPointParameters=...
        locCreateFixedPointParameters(nt);
        signalAttributes.ResolvedClassName=class(procData);

        for dataArrayIdx=1:numPts
            dataArray=data{dataArrayIdx};
            dataFi=dataArray;
            dataArray=simulinkarray(dataFi);
            lengthFi=length(dataFi);
            lengthContainer=length(dataArray);
            assert(mod(lengthContainer,lengthFi)==0);
            if lengthFi
                fiSampleSizeFactor=lengthContainer/lengthFi;
            end

            data{dataArrayIdx}=dataArray;
        end
    else
        signalAttributes.ClassName=class(procData);
        signalAttributes.ResolvedClassName='';
    end

    if isenum(procData)
        sc=superclasses(procData);
        valuesClass=sc{end};
        signalAttributes.ResolvedClassName=valuesClass;

        for dataArrayIdx=1:numPts
            data{dataArrayIdx}=real(data{dataArrayIdx});
        end
    end

    if signalAttributes.Complexity
        for dataArrayIdx=1:numPts
            dataArray=data{dataArrayIdx};
            dataInterlaced=zeros(size(dataArray,1)*2,1,class(dataArray));
            if fiSampleSizeFactor>1
                lengthData=length(dataArray);




                assert(mod(lengthData,fiSampleSizeFactor)==0);
                nElements=length(dataArray)/fiSampleSizeFactor;
                for elementNo=1:nElements
                    dataIdx=fiSampleSizeFactor*(elementNo-1);
                    dataInterlaced(...
                    dataIdx*2+1:dataIdx*2+fiSampleSizeFactor...
                    )=...
                    real(dataArray(dataIdx+1:dataIdx+fiSampleSizeFactor));
                    dataInterlaced(...
                    dataIdx*2+fiSampleSizeFactor+1:...
                    dataIdx*2+fiSampleSizeFactor*2...
                    )=...
                    imag(dataArray(dataIdx+1:dataIdx+fiSampleSizeFactor));
                end
            else
                dataInterlaced(1:2:end-1)=real(dataArray);
                dataInterlaced(2:2:end)=imag(dataArray);
            end
            data{dataArrayIdx}=dataInterlaced;
        end
    end

    if strcmp(signalAttributes.ClassName,'fixed-point')||...
        strcmp(signalAttributes.ClassName,'scaled-double')

        wordSize=8;
        fxpParams=signalAttributes.FixedPointParameters;
        while fxpParams.WordLength>wordSize
            wordSize=wordSize*2;
        end
        SampleSizeForData=min((wordSize/8),8);
        strct.isStreamingToV73=true;
        strct.fiSampleSizeFactor=fiSampleSizeFactor;
    elseif isenum(procData)
        SampleSizeForData=Simulink.SimulationData.Storage.MatFileDatasetStorage....
        ClassName2sampleSizeInBytes(signalAttributes.ResolvedClassName);
    else
        SampleSizeForData=Simulink.SimulationData.Storage.MatFileDatasetStorage....
        ClassName2sampleSizeInBytes(signalAttributes.ClassName);
    end

    SampleSizeForDims=Simulink.SimulationData.Storage.MatFileDatasetStorage....
    ClassName2sampleSizeInBytes('uint64');



    strct.DataR2=sigstream_mapi(...
    'r2CreateRecord',...
    r2,...
    SampleSizeForData,...
    0,...
    isequal(signalAttributes.ClassName,'half'),...
    []...
    );

    strct.VarDimsR2=sigstream_mapi(...
    'r2CreateRecord',...
    r2,...
    SampleSizeForDims,...
    0,...
    isequal(signalAttributes.ClassName,'half'),...
    []...
    );


    strct.NumVarDims=1;
    for dataArrayIdx=1:numPts
        dataArray=data{dataArrayIdx};

        dims=size(dataArray);
        if isvector(dataArray)
            strct.NumVarDims=max(1,strct.NumVarDims);
        else
            strct.NumVarDims=max(numel(dims),strct.NumVarDims);
        end
    end


    for dataArrayIdx=1:numPts
        dataArray=data{dataArrayIdx};
        dims=size(dataArray);
        numChannels=1;
        for dimsIdx=1:strct.NumVarDims


            if dimsIdx>numel(dims)
                sigstream_mapi(...
                'r2AppendSample',...
                r2,...
                strct.VarDimsR2,...
                uint64(1)...
                );
            else
                originalDims=uint64(dims(dimsIdx)/(complexityFactor*fiSampleSizeFactor));
                sigstream_mapi(...
                'r2AppendSample',...
                r2,...
                strct.VarDimsR2,...
originalDims...
                );

                numChannels=numChannels*dims(dimsIdx);
            end
        end

        for elemIdx=1:numChannels
            sigstream_mapi(...
            'r2AppendSample',...
            r2,...
            strct.DataR2,...
            dataArray(elemIdx)...
            );
        end
    end
end






function[data,signalAttributes]=locPreprocessData(origData,nSamples)

    data=origData;

    dimension=size(data);
    if nSamples~=1


        dimension(end)=[];
    end

    signalAttributes.Dimension=uint32(dimension)';
    signalAttributes.Complexity=~isreal(data)&&isnumeric(data);

    data=data(:);
    fiSampleSizeFactor=1;

    if isa(data,'embedded.fi')
        if~isscaleddouble(data)
            signalAttributes.ClassName='fixed-point';
        else
            signalAttributes.ClassName='scaled-double';
        end
        nt=numerictype(data);
        signalAttributes.FixedPointParameters=...
        locCreateFixedPointParameters(nt);

        dataFi=data;
        data=simulinkarray(dataFi);
        lengthFi=length(dataFi);
        lengthContainer=length(data);
        assert(mod(lengthContainer,lengthFi)==0);
        if lengthFi
            fiSampleSizeFactor=lengthContainer/lengthFi;
        end
        signalAttributes.ResolvedClassName=class(data);
    else
        signalAttributes.ClassName=class(data);
        signalAttributes.ResolvedClassName='';
    end

    if isenum(data)
        sc=superclasses(data);
        valuesClass=sc{end};
        data=cast(data,valuesClass);
        signalAttributes.ResolvedClassName=valuesClass;
    end

    if~isreal(data)&&isnumeric(data)
        dataInterlaced=zeros(size(data,1)*2,1,class(data));
        if fiSampleSizeFactor>1
            lengthData=length(data);




            assert(mod(lengthData,fiSampleSizeFactor)==0);
            nElements=length(data)/fiSampleSizeFactor;
            for elementNo=1:nElements
                dataIdx=fiSampleSizeFactor*(elementNo-1);
                dataInterlaced(...
                dataIdx*2+1:dataIdx*2+fiSampleSizeFactor...
                )=...
                real(data(dataIdx+1:dataIdx+fiSampleSizeFactor));
                dataInterlaced(...
                dataIdx*2+fiSampleSizeFactor+1:...
                dataIdx*2+fiSampleSizeFactor*2...
                )=...
                imag(data(dataIdx+1:dataIdx+fiSampleSizeFactor));
            end
        else
            dataInterlaced(1:2:end-1)=real(data);
            dataInterlaced(2:2:end)=imag(data);
        end
        data=dataInterlaced;
    end
end


function values=locConvertTStoTTatLeafRecursion(values)
    if isequal(numel(values),1)&&isfield(values,'ElementType')&&...
        ~isstruct(values.ElementType)
        values.ElementType='timetable';
        values.TableProps.Description='';


        values.TableProps.DimensionNames={'Time','Variables'};
        values.TableProps.TimeDisplayFormat='s';
        values.TableProps.TimeFormat='duration';
        values.TableProps.TimeUnits='seconds';
        values.TableProps.UserData=[];
        values.TableProps.VariableDescriptions={};
        values.TableProps.VariableNames={'Data'};

        values.TableProps.VariableUnits={};
        return;
    end

    names=fieldnames(values);
    for idx=1:numel(values)
        for jdx=1:numel(names)
            values(idx).(names{jdx})=locConvertTStoTTatLeafRecursion(values(idx).(names{jdx}));
        end
    end
end


function data=locVerifyMATandLoadData(r2,strct,nSamples)
    builtinTypes={'logical','int8','uint8',...
    'int16','uint16','int32','uint32',...
    'int64','uint64','half','single','double'};

    recordSampleSize=uint64(sigstream_mapi('getR2RecordSampleSize',...
    r2,...
    strct.DataR2));
    isMATFileDataCorrect=false;

    sigAttrs=struct();
    if isfield(strct,'SignalAttributes')
        sigAttrs=strct.SignalAttributes;
    end

    dataType="";
    if isfield(sigAttrs,'ClassName')
        dataType=sigAttrs.ClassName;
    end

    resolvedClassName="";
    if isfield(sigAttrs,'ResolvedClassName')
        resolvedClassName=sigAttrs.ResolvedClassName;
    end

    dimensionFactor=1;
    if isfield(sigAttrs,'Dimension')
        dimensionFactor=prod(sigAttrs.Dimension);
    end

    complexityFactor=1;
    if isfield(sigAttrs,'Complexity')&&sigAttrs.Complexity
        complexityFactor=2;
    end


    if isfield(strct,'VarDimsR2')&&~isempty(strct.VarDimsR2)
        rawVarDims=sigstream_mapi(...
        'getR2Data',...
        r2,...
        strct.VarDimsR2,...
        Simulink.SimulationData.Storage.MatFileDatasetStorage.R2VarDimsAttributes);

        sampleSizeMulFactor=1;
        totalSamples=sum(rawVarDims)*complexityFactor;
    else
        sampleSizeMulFactor=dimensionFactor*complexityFactor;
        totalSamples=nSamples*sampleSizeMulFactor;
    end

    data=[];
    switch dataType
    case 'string'
        isMATFileDataCorrect=recordSampleSize==sampleSizeMulFactor;
        if~isMATFileDataCorrect
            data=repmat("",[totalSamples,1]);
        end

    case 'fixed-point'
        fxpParams=strct.SignalAttributes.FixedPointParameters;
        wordSize=8;
        while fxpParams.WordLength>wordSize
            wordSize=wordSize*2;
        end
        sampleSize=(wordSize/8)*sampleSizeMulFactor;

        if isfield(strct,'isStreamingToV73')&&~isempty(strct.isStreamingToV73)
            sampleSize=min(sampleSize,8);
        end

        isMATFileDataCorrect=recordSampleSize==sampleSize;

        if~isMATFileDataCorrect



            data=zeros(totalSamples,1,'uint64');
        end

    case 'scaled-double'
        isMATFileDataCorrect=(recordSampleSize==(8*sampleSizeMulFactor));

        if~isMATFileDataCorrect



            data=zeros(totalSamples,1,'double');
        end

    case 'boolean'
        isMATFileDataCorrect=recordSampleSize==sampleSizeMulFactor;
        if~isMATFileDataCorrect
            data=zeros(totalSamples,1,'logical');
        end

    case builtinTypes
        dataTypeEval=eval(dataType+"(0)");
        sampleSize=whos("dataTypeEval").bytes*sampleSizeMulFactor;
        isMATFileDataCorrect=recordSampleSize==sampleSize;

        if~isMATFileDataCorrect
            data=zeros(totalSamples,1,dataType);
        end

    otherwise
        if~strcmp(resolvedClassName,"")
            resolvedDataType=strct.SignalAttributes.ResolvedClassName;
            dataTypeEval=eval(resolvedDataType+"(0)");
            sampleSize=whos("dataTypeEval").bytes*sampleSizeMulFactor;
            isMATFileDataCorrect=recordSampleSize==sampleSize;

            if~isMATFileDataCorrect
                en=enumeration(strct.SignalAttributes.ClassName);
                data=repmat(en(1),totalSamples,1);
            end
        end
    end

    if isMATFileDataCorrect
        data=sigstream_mapi(...
        'getR2Data',...
        r2,...
        strct.DataR2,...
        strct.SignalAttributes...
        );
    else




        wState=warning('off','backtrace');
        warning(message('SimulationData:Objects:MismatchClassSampleSizeMATFile',dataType,strct.Name));
        warning(wState);
    end
end





