




classdef(Abstract)DatasetStorage



    methods(Abstract,Hidden=true)
        nelem=numElements(this)
        meta=getMetaData(this,idx,prop)
        elem=getElements(this,idx)
        this=addElements(this,idx,elem)
        this=setElements(this,idx,elem)
        this=removeElements(this,idx)
        this=sortElements(this)
        obj=constructMcosLeafFromStructStorage(this,strct,varargin);
        this=convertTStoTTatLeaf(this);
        obj=getElementAsDatastore(this,varargin);
        [values,names,propNames,blockPaths]=utGetMetadataForDisplay(this);
    end
    methods(Abstract,Static,Hidden=true)
        obj=constructMcosTimeseriesFromStructStorage(strct,varargin)
        obj=constructMcosTimetableFromStructStorage(strct,varargin)
    end

    properties(Access=public,Hidden,Constant)
        LeafMarkerValue=char(uint16(65279));
    end

    properties(Hidden)
        ReturnAsDatastore=false;
    end

    methods
        function this=set.ReturnAsDatastore(this,retDS)
            validateattributes(retDS,{'logical'},{'scalar'});
            this.ReturnAsDatastore=retDS;
        end
    end

    methods(Hidden)

        function checkIdxRange(this,idx,maxIdx,err)



            if length(this)~=1
                Simulink.SimulationData.utError('InvalidDatasetArray');
            end

            if~isnumeric(idx)||~isreal(idx)||...
                any(idx~=uint32(idx))||min(idx)<1||max(idx)>maxIdx
                Simulink.SimulationData.utError(err,maxIdx);
            end
        end

    end


    methods(Static,Hidden=true)

        function tt=packTimeAndDataIntoTimetable(time,data,tt_props)
            if isempty(time)
                tt=timetable;
                return;
            end
            if~isempty(tt_props)
                if isequal(tt_props.TimeFormat,'duration')
                    tt=timetable(duration(seconds(time),'Format',...
                    tt_props.TimeDisplayFormat),...
                    data,'VariableNames',tt_props.VariableNames);
                else
                    tt=timetable(datetime(time,'ConvertFrom','datenum',...
                    'Format',tt_props.TimeDisplayFormat),...
                    data,'VariableNames',tt_props.VariableNames);
                end
                tt.Properties.DimensionNames=tt_props.DimensionNames;
                tt.Properties.Description=tt_props.Description;
                tt.Properties.UserData=tt_props.UserData;
                tt.Properties.VariableDescriptions=tt_props.VariableDescriptions;
                tt.Properties.VariableUnits=tt_props.VariableUnits;
                if isfield(tt_props,'VariableContinuity')
                    tt.Properties.VariableContinuity=tt_props.VariableContinuity;
                end
            else
                tt=timetable(seconds(time),data,'VariableNames',{'Data'});
            end
        end

        function dst=constructMcosSimulationDatastoreFromStructStorage(strct)
            assert(isequal(strct.ElementType,'simulation_datastore'),...
            'DatasetStorage::constructMcosSimulationDatastoreFromStructStorage: element type is incorrect');
            assert(isequal(strct.LeafMarker,...
            Simulink.SimulationData.Storage.DatasetStorage.LeafMarkerValue),...
            'DatasetStorage::constructMcosSimulationDatastoreFromStructStorage: element is not a leaf signal');

            if~strct.IsEmpty
                dst=matlab.io.datastore.SimulationDatastore.createForMATFile(...
                strct.FileName,...
                strct,...
                strct.StorageVersion...
                );
            else
                dst=matlab.io.datastore.SimulationDatastore.empty;
            end
        end


        function data_reshape=prepareDataForOutput(data,attribs,nSamples)

            className=attribs.ClassName;
            dims=attribs.Dimension;
            complexity=attribs.Complexity;
            dims_reshape=([dims;nSamples]);

            if(strcmp(className,'fixed-point')||...
                strcmp(className,'scaled-double')||...
                strcmp(className,'date-time')||...
                (strcmp(className,'half')&&isfield(attribs,'FixedPointParameters')))


                if~(isfield(attribs.FixedPointParameters,'isHalf')&&...
                    attribs.FixedPointParameters.isHalf)
                    data=Simulink.SimulationData.utFI.handleFixedPointType(...
                    data,attribs.FixedPointParameters,className);
                end

                if(strcmp(className,'date-time'))
                    epochYear=attribs.DateTimeParameters.Year;
                    epochMonth=attribs.DateTimeParameters.Month;
                    epochDay=attribs.DateTimeParameters.Day;
                    epochHour=attribs.DateTimeParameters.Hour;
                    epochMinute=attribs.DateTimeParameters.Minute;
                    epochSecond=attribs.DateTimeParameters.Second;
                    epoch=datetime(epochYear,epochMonth,epochDay,...
                    epochHour,epochMinute,epochSecond);
                    data=epoch+seconds(double(data));
                end
            elseif(strcmp(className,'string'))
                if(isfield(attribs.StringParameters,'isDynamic'))&&~attribs.StringParameters.isDynamic

                    maxLength=attribs.StringParameters.MaxLength;
                    stringData=repmat(string(''),[nSamples,1]);%#ok<STRQUOT>
                    if(maxLength>0)
                        for i=1:nSamples
                            currCharIdx=(i-1)*maxLength+1;
                            endMaxIdx=i*maxLength;
                            currStr=stringData(i);

                            while((data(currCharIdx)>0)&&(currCharIdx<endMaxIdx))
                                currStr=currStr+char(data(currCharIdx));
                                currCharIdx=currCharIdx+1;
                            end

                            stringData(i)=currStr;
                        end
                    else
                        strIdx=1;
                        currStr="";
                        for dataIdx=1:numel(data)
                            if data(dataIdx)==0
                                stringData(strIdx)=currStr;
                                strIdx=strIdx+1;
                                currStr="";
                            else
                                currStr=currStr+char(data(dataIdx));
                            end
                        end
                    end
                    data=stringData;
                elseif(((~isequal(class(data),'string'))||(length(data)~=nSamples)))


                    data=repmat(string(''),[nSamples,1]);%#ok<STRQUOT>
                end
            elseif strcmp(className,'boolean')
                data=logical(data);
            else
                if(~strcmp(className,'double')&&...
                    ~strcmp(className,'single')&&...
                    ~strcmp(className,'int8')&&...
                    ~strcmp(className,'uint8')&&...
                    ~strcmp(className,'int16')&&...
                    ~strcmp(className,'uint16')&&...
                    ~strcmp(className,'int32')&&...
                    ~strcmp(className,'uint32')&&...
                    ~strcmp(className,'logical'))
                    sw=warning('off');
                    tmp=onCleanup(@()warning(sw));
                    try
                        fh=str2func(className);
                        data=fh(data);
                    catch me %#ok<NASGU> 
                        delete(tmp);
                        sw=warning('OFF','BACKTRACE');
                        tmp=onCleanup(@()warning(sw));
                        warning(message('SimulationData:Objects:DatasetLoadEnumWarn',className,class(data)));
                    end
                    delete(tmp);
                end
            end

            if complexity==true&&isreal(data)
                data_complex=complex(data(1:2:end-1),data(2:2:end));
            else
                data_complex=data;
            end

            data_reshape=reshape(data_complex,dims_reshape');

            if length(dims)==1
                if strcmp(className,'logical')
                    data_reshape=data_reshape';
                else
                    data_reshape=data_reshape.';
                end
            end
        end


        function obj=constructMcosElementFromStructStorage(storage,strct,varargin)











            if~isfield(strct,'ElementType')||~ischar(strct.ElementType)





                obj=Simulink.SimulationData.TransparentElement;
                obj.Values=locConstructMcosValuesFromStructStorage(...
                storage,...
                strct,...
                varargin{:});
            elseif strcmp(strct.ElementType,'signal')
                obj=locConstructMcosSignalFromStructStorage(...
                storage,...
                strct,...
                varargin{:}...
                );
            elseif strcmp(strct.ElementType,'param')
                obj=locConstructMcosParamFromStructStorage(...
                storage,...
                strct,...
                varargin{:}...
                );
            elseif strcmp(strct.ElementType,'assessment')
                obj=locConstructMcosAssessmentFromStructStorage(...
                storage,...
                strct,...
                varargin{:}...
                );
            elseif strcmp(strct.ElementType,'state')
                obj=locConstructMcosStateFromStructStorage(...
                storage,...
                strct,...
                varargin{:}...
                );
            elseif strcmp(strct.ElementType,'dsm')
                obj=locConstructMcosDsmFromStructStorage(...
                storage,...
                strct,...
                varargin{:}...
                );
            elseif strcmp(strct.ElementType,'sfstate')||...
                strcmp(strct.ElementType,'sfdata')||...
                strcmp(strct.ElementType,'sfchartactivity')
                obj=locConstructMcosSfElementFromStructStorage(...
                storage,...
                strct,...
                varargin{:}...
                );
            elseif strcmp(strct.ElementType,'timeseries')
                if~storage.ReturnAsDatastore
                    obj=storage.constructMcosTimeseriesFromStructStorage(...
                    strct,...
                    varargin{:}...
                    );
                else
                    obj=storage.getElementAsDatastore(strct,varargin{:});
                end
            elseif strcmp(strct.ElementType,'transparent_element')
                obj=locConstructMcosTransparentElementFromStructStorage(...
                storage,...
                strct,...
                varargin{:}...
                );
            elseif strcmp(strct.ElementType,'timetable')
                if~this.ReturnAsDatastore
                    obj=storage.constructMcosTimetableFromStructStorage(...
                    strct,...
                    varargin{:}...
                    );
                else
                    obj=storage.getElementAsDatastore(strct,varargin{:});
                end
            elseif strcmp(strct.ElementType,'simulation_datastore')
                obj=storage.constructMcosSimulationDatastoreFromStructStorage(...
                strct,...
                varargin{:}...
                );
            elseif strcmp(strct.ElementType,'dataset')
                obj=locConstructMcosNestedDatasetFromStructStorage(...
                storage,...
                strct,...
                varargin{:}...
                );
            elseif strcmp(strct.ElementType,'blockdata')
                obj=locConstructMcosBlockDatatFromStructStorage(...
                storage,...
                strct,...
                varargin{:}...
                );
            else

                obj=strct;
            end
        end


        function units=constructMcosUnitsFromStructStorage(s)
            if~isstruct(s)
                units=s;
                return
            end
            if strcmp(s.Class,'Simulink.SimulationData.Unit')
                units=Simulink.SimulationData.Unit(s.Value);
            else
                units=s.Value;
            end
        end


        function s=constructStructStorageFromUnits(units)
            s.Class=class(units);
            if isa(units,'Simulink.SimulationData.Unit')
                s.Value=units.Name;
            else
                s.Value=units;
            end
        end


        function DSMWritersAttributes=createDSMWritersAttributes
            DSMWritersAttributes.ClassName='uint32';
            DSMWritersAttributes.ResolvedClassName='';
            DSMWritersAttributes.Dimension=uint32(1);
            DSMWritersAttributes.Complexity=logical(false);
        end


        function answer=isBuiltinType(className)
            answer=...
            strcmp(className,'double')||...
            strcmp(className,'single')||...
            strcmp(className,'half')||...
            strcmp(className,'int8')||...
            strcmp(className,'uint8')||...
            strcmp(className,'int16')||...
            strcmp(className,'uint16')||...
            strcmp(className,'int32')||...
            strcmp(className,'uint32')||...
            strcmp(className,'int64')||...
            strcmp(className,'uint64')||...
            strcmp(className,'logical')||...
            strcmp(className,'char')||...
            strcmp(className,'string');
        end
    end
end


function obj=locConstructMcosDsmFromStructStorage(storage,strct,varargin)
    assert(strcmp(strct.ElementType,'dsm'),...
    'DatasetStorage::locConstructMcosDsmFromStructStorage non-dsm');

    obj=Simulink.SimulationData.DataStoreMemory;
    obj.Name=strct.Name;
    obj.BlockPath=strct.BlockPath;
    obj=obj.utSetScope(strct.Scope);
    obj=obj.utSetWriters(strct.DSMWriterBlockPaths);

    if isfield(strct,'DSMWritersR2')&&~isempty(strct.DSMWritersR2)
        r2=varargin{1};
        DSMWritersAttributes=...
        Simulink.SimulationData.Storage.DatasetStorage....
        createDSMWritersAttributes;
        DSMWriters=...
        sigstream_mapi(...
        'getR2Data',...
        r2,...
        strct.DSMWritersR2,...
DSMWritersAttributes...
        );
        obj=obj.utSetWriterIndices(DSMWriters);
    elseif isfield(strct,'DSMWriters')
        obj=obj.utSetWriterIndices(strct.DSMWriters);
    end

    [obj.Values,vData]=locConstructMcosValuesFromStructStorage(...
    storage,...
    strct.Values,...
    varargin{:}...
    );

    if~isempty(vData)
        obj=obj.setVisualizationMetadata(vData);
    end
end


function obj=locConstructMcosNestedDatasetFromStructStorage(storage,...
    strct,...
    varargin)
    obj=Simulink.SimulationData.Dataset;
    obj.Name=strct.Name;
    for ndx=1:numel(strct.Values)
        [obj{ndx},~]=locConstructMcosValuesFromStructStorage(storage,...
        strct.Values{ndx},varargin{:});
    end

end


function obj=locConstructMcosSfElementFromStructStorage(...
    storage,...
    strct,...
varargin...
    )

    if strcmp(strct.ElementType,'sfstate')
        obj=Stateflow.SimulationData.State;
    elseif strcmp(strct.ElementType,'sfdata')
        obj=Stateflow.SimulationData.Data;
    else
        assert(strcmp(strct.ElementType,'sfchartactivity'));
        obj=Stateflow.SimulationData.ChartActivity;
    end
    obj.Name=strct.Name;
    obj.BlockPath=Simulink.SimulationData.BlockPath(...
    strct.BlockPath,...
    strct.BlockSubPath...
    );
    [obj.Values,~]=locConstructMcosValuesFromStructStorage(...
    storage,...
    strct.Values,...
    varargin{:}...
    );
end


function obj=locConstructMcosSignalFromStructStorage(storage,strct,varargin)
    assert(strcmp(strct.ElementType,'signal'));
    obj=Simulink.SimulationData.Signal;
    obj.PortType=strct.PortType;
    obj.PortIndex=strct.PortIndex;
    blockPath=Simulink.SimulationData.BlockPath(strct.BlockPath,'');
    obj.BlockPath=blockPath;
    [obj.Values,vData]=locConstructMcosValuesFromStructStorage(...
    storage,...
    strct.Values,...
    varargin{:}...
    );
    if~isempty(vData)
        obj=obj.setVisualizationMetadata(vData);
    end
    obj.PropagatedName=strct.PropagatedName;
    obj.Name=strct.Name;
end
function obj=locConstructMcosBlockDatatFromStructStorage(storage,strct,varargin)


    obj=strct.Object;
    [obj.Values,vData]=locConstructMcosValuesFromStructStorage(...
    storage,...
    strct.Values,...
    varargin{:}...
    );
    if~isempty(vData)
        obj=obj.setVisualizationMetadata(vData);
    end
end

function obj=locConstructMcosStateFromStructStorage(storage,strct,varargin)
    assert(strcmp(strct.ElementType,'state'));
    obj=Simulink.SimulationData.State;
    obj.Label=strct.StateType;
    blockPath=Simulink.SimulationData.BlockPath(strct.BlockPath,'');
    obj.BlockPath=blockPath;
    [obj.Values,~]=locConstructMcosValuesFromStructStorage(...
    storage,...
    strct.Values,...
    varargin{:}...
    );
    obj.Name=strct.Name;
end


function obj=locConstructMcosTransparentElementFromStructStorage(...
    storage,...
    strct,...
varargin...
    )

    assert(...
    strcmp(strct.ElementType,'transparent_element'),...
    [...
    'DatasetStorage::',...
    'locConstructMcosTransparentElementFromStructStorage is called on ',...
'a struct where ElementType field is not ''transparent_element'''...
    ]...
    );
    obj=Simulink.SimulationData.TransparentElement;
    [obj.Values,~]=locConstructMcosValuesFromStructStorage(...
    storage,...
    strct.Values,...
    varargin{:}...
    );
    obj.Name=strct.Name;
end

function[isTT,isDST]=locIsLeafStrctTimetableOrDST(strct)



    isTT=false;
    isDST=false;

    if isfield(strct,'ElementType')
        if isequal(strct.ElementType,'timetable')
            isTT=true;
        elseif isequal(strct.ElementType,'simulation_datastore')
            isDST=true;
        end
    end
end


function[obj,vData]=locConstructMcosValuesFromStructStorage(...
    storage,...
    strct,...
varargin...
    )




    vData=Simulink.SimulationData.VisualizationMetadata();

    if isempty(strct)
        obj=[];
    elseif locIsStructLeafSignal(strct)
        [isTT,isDST]=locIsLeafStrctTimetableOrDST(strct);
        if isfield(strct,'IsEmpty')&&strct(1).IsEmpty
            assert(isscalar(strct));
            if isTT&&~storage.ReturnAsDatastore
                obj=timetable.empty;
            elseif isDST||(isTT&&storage.ReturnAsDatastore)
                obj=storage.constructMcosLeafFromStructStorage(...
                strct,...
                varargin{:});
            elseif storage.ReturnAsDatastore
                obj=matlab.io.datastore.SimulationDatastore.empty;
            else
                obj=timeseries.empty;
            end
        else
            if~isTT||storage.ReturnAsDatastore
                for idx=1:numel(strct)


                    [obj(idx),vData(idx)]=...
                    storage.constructMcosLeafFromStructStorage(...
                    strct(idx),...
                    varargin{:}...
                    );%#ok<AGROW>
                end
                obj=reshape(obj,size(strct));
            else
                if(numel(strct)==1)
                    obj=storage.constructMcosLeafFromStructStorage(...
                    strct,...
                    varargin{:}...
                    );
                else
                    obj=cell(numel(strct),1);
                    for idx=1:numel(strct)
                        obj{idx}=...
                        storage.constructMcosLeafFromStructStorage(...
                        strct(idx),...
                        varargin{:}...
                        );
                    end
                    obj=reshape(obj,size(strct));
                end
            end
        end
    elseif isstruct(strct)
        if isfield(strct,'ForeachDimensions')
            numElements=length(strct.ForeachElements);
            if numElements>0
                [isTT,~]=locIsLeafStrctTimetableOrDST(strct.ForeachElements{1});
            else
                if isfield(strct,'SignalType')&&isequal(strct.SignalType,'timetable')
                    obj={};
                else
                    obj=[];
                end
                return;
            end
            if~isTT||storage.ReturnAsDatastore


                for celIdx=1:numElements
                    obj(celIdx)=...
                    storage.constructMcosLeafFromStructStorage(...
                    strct.ForeachElements{celIdx},...
                    varargin{:}...
                    );%#ok<AGROW>                                
                end
            else
                obj=cell(numElements,1);
                for celIdx=1:numElements
                    obj{celIdx}=...
                    storage.constructMcosLeafFromStructStorage(...
                    strct.ForeachElements{celIdx},...
                    varargin{:}...
                    );
                end
            end







            if~isfield(strct,'ForeachNeedsPermuteDims')||strct.ForeachNeedsPermuteDims


                obj=reshape(obj,flip(strct.ForeachDimensions));
                obj=permute(obj,flip(1:length(strct.ForeachDimensions)));
            else
                obj=reshape(obj,strct.ForeachDimensions);
            end
        elseif isfield(strct,'ElementType')&&ischar(strct.ElementType)&&...
            ~isempty(strct.ElementType)
            obj=Simulink.SimulationData.Storage.DatasetStorage....
            constructMcosElementFromStructStorage(...
            storage,...
            strct,...
            varargin{:}...
            );
        else

            fields=fieldnames(strct);
            dim=[length(fields),size(strct)];
            emptyData=cell(dim);
            obj=cell2struct(emptyData,fields,1);
            vData=cell2struct(emptyData,fields,1);
            for idx=1:numel(strct)
                for fieldIdx=1:length(fields)
                    field=fields{fieldIdx};

                    [obj(idx).(field),vData(idx).(field)]=...
                    locConstructMcosValuesFromStructStorage(...
                    storage,...
                    strct(idx).(field),...
                    varargin{:}...
                    );
                end
            end
        end
    else
        if~storage.ReturnAsDatastore
            obj=strct;
        else
            Simulink.SimulationData.utError(...
            'DatastoreRepresentationNotSupportedForDataType');
        end
    end
end


function isScalarStructLeafSignal=locIsScalarStructLeafSignal(strct)


    isScalarStructLeafSignal=...
    locIsStructWithLeafMarker(strct)||...
    locIsStructLeafWithSignalAttributes(strct);
end


function isStructLeafSignal=locIsStructLeafSignal(strct)
    if~isstruct(strct)
        isStructLeafSignal=false;
        return;
    end
    isStructLeafSignal=locIsScalarStructLeafSignal(strct(1));
    if isStructLeafSignal
        for idx=2:numel(strct)
            assert(locIsScalarStructLeafSignal(strct(idx)));
        end
    end
end


function isStructLeafWithSignalAttributes=...
    locIsStructLeafWithSignalAttributes(strct)

    isStructLeafWithSignalAttributes=...
    isstruct(strct)&&...
    isfield(strct,'SignalAttributes');
end


function isStructWithLeafMarker=locIsStructWithLeafMarker(strct)


    isStructWithLeafMarker=...
    isstruct(strct)&&...
    isfield(strct,'LeafMarker')&&...
    isscalar(strct.LeafMarker)&&...
    ischar(strct.LeafMarker)&&...
    strct.LeafMarker==...
    Simulink.SimulationData.Storage.DatasetStorage.LeafMarkerValue;
end


function obj=locConstructMcosAssessmentFromStructStorage(storage,strct,varargin)
    obj=sltest.Assessment;
    obj.Name=strct.Name;
    obj.Result=slTestResult(strct.Result);
    obj.SSIdNumber=strct.SSIdNumber;
    obj.AssessmentId=strct.AssessmentId;
    obj.BlockPath=Simulink.SimulationData.BlockPath(strct.BlockPath,strct.BlockSubPath);
    obj.Values=locConstructMcosValuesFromStructStorage(...
    storage,...
    strct.Values,...
    varargin{:}...
    );
end


function obj=locConstructMcosParamFromStructStorage(storage,strct,varargin)
    obj=Simulink.SimulationData.Parameter;
    obj.Name=strct.Name;
    subPath='';
    if isfield(strct,'BlockSubPath')
        subPath=strct.BlockSubPath;
    end
    obj.BlockPath=Simulink.SimulationData.BlockPath(strct.BlockPath,subPath);
    obj.Values=locConstructMcosValuesFromStructStorage(...
    storage,...
    strct.Values,...
    varargin{:}...
    );
end



