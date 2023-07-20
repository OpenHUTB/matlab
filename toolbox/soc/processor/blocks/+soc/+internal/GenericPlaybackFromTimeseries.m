classdef GenericPlaybackFromTimeseries<matlab.System



    properties(Nontunable)
        ObjectName='';
        TopBlockType='IO Data Source';

        SampleTime=0.1;
        UseRandomInitialValue=true;
        DataType='double';
        Dimensions=1;
    end


    properties(Access=private)
        NumberOfPorts;
        DataIndex=1;
        TimeseriesData=[];
        TimeseriesDataInitialized=false;
    end

    methods
        function obj=GenericPlaybackFromTimeseries(varargin)

            obj.NumberOfPorts=1;
            setProperties(obj,nargin,varargin{:});
        end
        function set.SampleTime(obj,newTime)
            coder.extrinsic('error');
            coder.extrinsic('message');
            if isLocked(obj)
                error(message('ioplayback:general:SampleTimeNonTunable'))
            end

            obj.SampleTime=newTime;
        end
        function checkDataFile(obj,dataFile)%#ok<INUSD>
            if isempty(coder.target)
            end
        end
    end


    methods(Hidden,Access=protected)
        function setSimulationOutput(obj,val)
            obj.SimulationOutput=val;
        end
        function setSourceName(obj,val)
            obj.SourceName=val;
        end
        function setDatasetName(obj,val)
            obj.DatasetName=val;
        end
        function setDataType(obj,val)
            obj.DataType=val;
        end
        function st=getSampleTimeImpl(obj)
            if obj.SampleTime>0
                st=createSampleTime(obj,'Type','Discrete',...
                'SampleTime',obj.SampleTime);
            else
                st=createSampleTime(obj,'Type','Inherited');
            end
        end
        function setupTimeseriesObject(obj)
            if~obj.TimeseriesDataInitialized
                tsObj=soc.internal.getTimeseriesObject(obj.ObjectName,...
                obj.TopBlockType);
                switch obj.TopBlockType
                case 'Interrupt Event Source'
                    obj.TimeseriesData=ones(length(tsObj.Time),1);
                otherwise
                    obj.TimeseriesData=tsObj.Data;
                end
                obj.TimeseriesDataInitialized=true;
            end
        end
    end

    methods(Access=protected)

        function setupImpl(obj)
        end
        function varargout=stepImpl(obj,varargin)
            if(obj.DataIndex<=length(obj.TimeseriesData))
                data=obj.TimeseriesData(obj.DataIndex,:);
                len=length(data);
                varargout{1}=feval(obj.DataType,data);
                varargout{2}=true;
                varargout{3}=uint32(len);
                obj.DataIndex=obj.DataIndex+1;
            else

                assert(false,'Out of bounds for timeseries object data');
            end
        end


        function ds=getDiscreteStateImpl(obj)%#ok<MANU>
            ds=struct([]);
        end
        function flag=isInputSizeMutableImpl(~,~)

            flag=false;
        end
        function num=getNumInputsImpl(~)
            num=0;
        end
        function num=getNumOutputsImpl(obj)%#ok<MANU>
            num=3;
        end
        function[data,valid,length]=isOutputFixedSizeImpl(obj)%#ok<MANU>
            data=true;
            valid=true;
            length=true;
        end
        function[data,valid,length]=getOutputDataTypeImpl(obj)
            data=obj.DataType;
            valid='logical';
            length='uint32';
        end
        function[data,valid,length]=isOutputComplexImpl(~)
            data=false;
            valid=false;
            length=false;
        end
        function[data,valid,length]=getOutputSizeImpl(obj)

            setupTimeseriesObject(obj);
            tsObjDataSz=size(obj.TimeseriesData);
            data=[1,tsObjDataSz(2)];
            valid=1;
            length=1;
        end
        function icon=getIconImpl(obj)%#ok<MANU>
            icon={'From timeseries'};
        end
    end

    methods(Static,Access=protected)

        function header=getHeaderImpl

            header=matlab.system.display.Header(mfilename("class"),...
            'Title','Generic block',...
            'Text','This block outputs data from timeseries');
        end
        function simMode=getSimulateUsingImpl
            simMode='Interpreted execution';
        end
    end

    methods(Access=protected)
        function flag=isInactivePropertyImpl(obj,propertyName)
            if strcmp(propertyName,'SimulationOutput')
                flag=obj.UseRandomInitialValue;
            else
                flag=false;
            end
        end
    end
end
