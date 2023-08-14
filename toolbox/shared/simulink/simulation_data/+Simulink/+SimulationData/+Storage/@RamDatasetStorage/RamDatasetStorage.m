



classdef RamDatasetStorage<Simulink.SimulationData.Storage.DatasetStorage


    properties(Access='protected',Transient,Constant)
        CurrentVersion_=2;
    end


    properties(Access='protected')


        Version=Simulink.SimulationData.Storage.RamDatasetStorage.CurrentVersion_;
        Elements={};
    end


    methods(Hidden=true)

        function[obj,vData]=constructMcosLeafFromStructStorage(this,strct,varargin)



            if~isfield(strct,'ElementType')||isequal(strct.ElementType,'timeseries')
                obj=this.constructMcosTimeseriesFromStructStorage(...
                strct,...
                varargin{:}...
                );
            elseif isequal(strct.ElementType,'timetable')
                obj=this.constructMcosTimetableFromStructStorage(strct,...
                varargin{:});
            else
                assert(isequal(strct.ElementType,'simulation_datastore'),...
                'RamDatasetStorage::constructMcosLeafFromStructStorage: unexpected ElementType Value');
                obj=...
                this.constructMcosSimulationDatastoreFromStructStorage(strct);
            end

            vData=Simulink.SimulationData.VisualizationMetadata();
            if isfield(strct,'SampleTime')
                vData.SampleTime=strct.SampleTime;
            end
            if isfield(strct,'AliasName')
                vData.AliasTypeName=strct.AliasName;
            end
        end


        function nelem=numElements(this)
            if length(this)~=1
                Simulink.SimulationData.utError('InvalidDatasetArray');
            end
            nelem=length(this.Elements);
        end


        function meta=getMetaData(this,idx,prop)

            if isempty(this.Elements)
                Simulink.SimulationData.utError('InvalidDatasetGetIndexEmpty');
            end

            this.checkIdxRange(...
            idx,...
            this.numElements(),...
'InvalidDatasetGetIndex'...
            );

            meta=this.Elements{idx}.(prop);
        end


        function element=getElements(this,idx)

            if isempty(this.Elements)
                Simulink.SimulationData.utError('InvalidDatasetGetIndexEmpty');
            end

            this.checkIdxRange(idx,this.numElements(),'InvalidDatasetGetIndex');
            if~this.ReturnAsDatastore
                if isscalar(idx)
                    element=this.Elements{idx};
                else
                    element=this.Elements(idx);
                end
            else
                if isscalar(idx)
                    element=this.getElementAsDatastore(this.Elements{idx});
                else
                    elements=cell(1,length(idx));
                    for jdx=1:length(idx)
                        elements{jdx}=this.getElementAsDatastore(this.Elements{jdx});
                    end
                end
            end
        end


        function version=getVersion(this)
            version=this.Version;
        end


        function this=setElements(this,idx,element)

            this.checkIdxRange(idx,this.numElements(),'DatasetSetInvalidIdx');
            if isscalar(idx)
                this.Elements{idx}=element;
            else
                this.Elements(idx)=element;
            end
        end


        function this=addElements(this,idx,element)

            this.checkIdxRange(idx,this.numElements()+1,'DatasetInsertInvalidIdx');
            if~isscalar(idx)
                Simulink.SimulationData.utError(...
                'DatasetInsertInvalidIdx',maxIdx);
            end

            this.Elements=[this.Elements(1:idx-1),cell(1,length(element)),this.Elements(idx:end)];
            try
                this=this.setElements(idx:idx+length(element)-1,element);
            catch me
                throwAsCaller(me);
            end

        end


        function this=removeElements(this,idx)

            this.checkIdxRange(idx,this.numElements(),'DatasetRemoveInvalidIdx');

            this.Elements(idx)=[];
        end



        function this=utSetElements(this,elements)



            if isrow(elements)
                this.Elements=elements;
            else
                this.Elements=elements';
            end
        end


        function answer=isRilDsDstCapable(this)
            if isempty(this.Elements)
                answer=false;
                return
            end
            for elementIdx=1:length(this.Elements)
                element=this.Elements{elementIdx};
                if isa(element,'Simulink.SimulationData.BlockData')||...
                    isa(element,...
                    'Simulink.SimulationData.TransparentElement')
                    values=element.Values;
                else
                    values=element;
                end
                elementIsRilDsDstCapable=false;
                if isempty(values)
                    elementIsRilDsDstCapable=false;
                elseif isa(values,'timeseries')
                    elementIsRilDsDstCapable=...
                    isscalar(values)&&...
                    isreal(values.Data)&&...
                    locSampleIsScalarTimeseries(values)&&...
                    isa(values.Data,'double')&&...
                    all(isfinite(values.Data(:)));
                elseif isa(values,'matlab.io.datastore.SimulationDatastore')
                    elementIsRilDsDstCapable=...
                    isscalar(values)&&...
                    values.getSimImplProps.SignalAttributesData_.Complexity==false&&...
                    strcmp(values.getSimImplProps.SignalAttributesData_.ClassName,'double');
                end
                if~elementIsRilDsDstCapable
                    answer=false;
                    return
                end
            end
            answer=true;
        end


        function elements=utGetElements(this)
            elements=this.Elements;
        end


        function this=convertTStoTTatLeaf(this)
            for idx=1:numel(this.Elements)

                if isa(this.Elements{idx},'timeseries')
                    this.Elements{idx}=...
                    Simulink.SimulationData.TimeseriesUtil.convertTimeSeriesToTimeTable(this.Elements{idx});
                else
                    this.Elements{idx}.Values=...
                    locConvertToTimetableRecursion(this.Elements{idx}.Values);
                end
            end
        end

        function dst=getElementAsDatastore(~,varargin)


            Simulink.SimulationData.utError(...
            'DatastoreRepresentationNotSupported');
            dst=matlab.io.datastore.SimulationDatastore.empty;

        end

        function[values,names,propNames,blockPaths]=utGetMetadataForDisplay(this)
            n=numElements(this);
            values=cell(n,1);
            names=cell(n,1);
            propNames=cell(n,1);
            blockPaths=cell(n,1);
            for idx=1:n
                if~isempty(this.Elements{idx})


                    elm=this.Elements{idx};
                    if isa(elm,'Simulink.SimulationData.TransparentElement')
                        val=elm.Values;
                    else
                        val=elm;
                    end
                    if numel(val)>0&&isa(val,'timetable')
                        str=sprintf('%dx%d',length(val.Properties.RowTimes),...
                        length(val.Properties.VariableNames));
                        classSplits=split(class(val),'.');
                        values{idx}=sprintf('%s %s',str,classSplits{end});
                    else
                        str=sprintf('%dx',size(val));
                        classSplits=split(class(val),'.');
                        values{idx}=sprintf('%s %s',str(1:end-1),classSplits{end});
                    end


                    if isequal(class(elm),'sltest.Assessment')
                        names{idx}=elm.getDisplayStr();
                    else
                        names{idx}=elm.Name;
                    end


                    if isprop(elm,'PropagatedName')
                        propNames{idx}=elm.PropagatedName;
                    else
                        propNames{idx}='';
                    end


                    if isa(elm,'Simulink.SimulationData.BlockData')
                        blockPaths{idx}=strjoin(elm.BlockPath.convertToCell(),'|');
                    else
                        blockPaths{idx}='';
                    end
                end
            end
        end


        this=sortElements(this);
        this=utfillfromstruct(this,datasetStruct);

    end


    methods(Access=private,Hidden=true)


        function strct=saveobj(this)
            strct.Version=this.Version;
            strct.Elements=this.Elements;
        end
    end


    methods(Static=true,Hidden=true)


        function obj=loadobj(strct)
            obj=Simulink.SimulationData.Storage.RamDatasetStorage;
            obj.Elements=strct.Elements;
            if strct.Version>Simulink.SimulationData.Storage.RamDatasetStorage.CurrentVersion_
                Simulink.SimulationData.utError('LoadingNewerVersionNotAllowed',...
                'Simulink.SimulationData.Storage.RamDatasetStorage');
            end
        end


        function obj=constructMcosTimeseriesFromStructStorage(strct,varargin)




            assert(isempty(varargin));

            if isa(strct,'timeseries')
                obj=strct;
                return
            end

            if strct.IsEmpty
                obj=timeseries.empty;
                return
            end
            isCompressedTime=isfield(strct,'CompressedTime');
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
                assert(isfield(strct,'Time'));
                time=strct.Time;
                nSamples=length(time);
            end

            data=strct.Data;

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
            obj.TimeInfo.Units=...
            Simulink.SimulationData.Storage.DatasetStorage....
            constructMcosUnitsFromStructStorage(strct.TimeUnits);
            if(~isempty(strct.StartDate))
                obj.TimeInfo.StartDate=eval(strct.StartDate);
                obj.TimeInfo.Format='yyyy-mm-dd HH:MM:SS';
            end
            obj.DataInfo.Units=...
            Simulink.SimulationData.Storage.DatasetStorage....
            constructMcosUnitsFromStructStorage(strct.DataUnits);
        end


        function tt=constructMcosTimetableFromStructStorage(strct,varargin)

            assert(~isa(strct,'timetable'),...
            'RAMFileDatasetStorage::constructMcosTimetableFromStructStorage: struct representation is invalid');

            if isfield(strct,'IsEmpty')&&strct.IsEmpty
                tt=timetable.empty;
                return
            end

            isCompressedTime=isfield(strct,'CompressedTime');
            if isCompressedTime
                if length(strct.CompressedTime)~=3
                    time=strct.CompressedTime;
                    nSamples=length(time);
                else
                    starttime=strct.CompressedTime(1);
                    increment=strct.CompressedTime(2);
                    len=strct.CompressedTime(3);
                    nSamples=len;
                    time=(starttime:increment:(len-1)*increment)';
                end
            else
                assert(isfield(strct,'Time'));
                time=strct.Time;
                nSamples=length(time);
            end



            data=strct.Data;
            data_reshape=Simulink.SimulationData.Storage.DatasetStorage....
            prepareDataForOutput(...
            data,...
            strct.SignalAttributes,...
nSamples...
            );

            if~isvector(data_reshape)
                retDataSize=size(data_reshape);
                dimIdx=1:length(retDataSize);
                data=permute(data_reshape,circshift(dimIdx,1));
            else
                data=data_reshape(:);
            end

            tt=timetable(seconds(time),data,'VariableNames',...
            strct.TableProps.VariableNames);

            tt.Properties.Description=strct.TableProps.Description;
            tt.Properties.UserData=strct.TableProps.UserData;
            tt.Properties.VariableDescriptions=strct.TableProps.VariableDescriptions;
            tt.Properties.VariableUnits=...
            Simulink.SimulationData.Storage.DatasetStorage....
            constructMcosUnitsFromStructStorage(...
            strct.TableProps.VariableUnits...
            );
        end
    end
end


function values=locConvertToTimetableRecursion(values)
    if isa(values,'timeseries')
        values=Simulink.SimulationData.TimeseriesUtil.convertTimeSeriesToTimeTable(values);
        return;
    end

    for idx=1:numel(values)
        if~isa(values,'timeseries')
            fNames=fieldnames(values(idx));
            for jdx=1:numel(fNames)
                values(idx).(fNames{jdx})=locConvertToTimetableRecursion(values(idx).(fNames{jdx}));
            end
        end
    end
end


function result=locSampleIsScalarTimeseries(ts)
    dim=size(ts.Data);
    if ts.IsTimeFirst
        assert(length(dim)==2);
        result=dim(2)==1;
    else
        result=all(dim(1:end-1)==1);
    end
end


