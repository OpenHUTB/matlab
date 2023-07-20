classdef GenericPlaybackTimer<ioplayback.SourceSystem



    properties(Nontunable)

        SampleTime=0.1;
        UseRandomInitialValue=true;
        DataType='double';
        Dimensions=1;
    end


    properties(Access=private)
NumberOfPorts
        SamplesCount=1;
    end

    methods

        function obj=GenericPlaybackTimer(varargin)


            obj.SimulationOutput='From recorded file';
            obj.DataFileFormat='Timestamp';
            obj.NumberOfPorts=1;
            obj.SignalInfo(obj.NumberOfPorts)=ioplayback.internal.SignalInfo;
            obj.SignalInfo(1).IsComplex=false;
            obj.DataTypeWarningasError=0;
            setProperties(obj,nargin,varargin{:})
        end
        function set.SampleTime(obj,newTime)
            coder.extrinsic('error');
            coder.extrinsic('message');
            if isLocked(obj)
                error(message('ioplayback:general:SampleTimeNonTunable'))
            end
            newTime=ioplayback.internal.validateSampleTime(newTime);
            obj.SampleTime=newTime;
        end


        function y=readData(~,~)

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
    end

    methods(Access=protected)

        function setupImpl(obj)

            setupImpl@ioplayback.SourceSystem(obj);
            setup(obj.Reader,1);
        end

        function varargout=stepImpl(obj,varargin)
            [data,len]=stepImpl@ioplayback.SourceSystem(obj,1);%#ok<AGROW>
            if obj.SamplesCount<=numel(obj.Reader.Ts)
                varargout{1}=data';
                varargout{2}=true;
                varargout{3}=uint32(len);
                obj.SamplesCount=obj.SamplesCount+1;
            else
                varargout{1}=data';
                varargout{2}=false;
                varargout{3}=uint32(len);
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
        function[Data,Valid,Length]=isOutputFixedSizeImpl(obj)%#ok<MANU>

            Data=true;
            Valid=true;
            Length=true;
        end

        function[Data,Valid,Length]=getOutputDataTypeImpl(obj)

            obj.SignalInfo(1).DataType=obj.DataType;
            Data=obj.SignalInfo(1).DataType;
            Valid='logical';
            Length='uint32';
        end

        function[Data,Valid,Length]=isOutputComplexImpl(~)

            Data=false;
            Valid=false;
            Length=false;
        end

        function[Data,Valid,Length]=getOutputSizeImpl(obj)

            obj.SignalInfo(1).Dimensions=obj.Dimensions;
            Data=[1,prod(obj.SignalInfo(1).Dimensions)];
            Valid=1;
            Length=1;
        end

        function icon=getIconImpl(obj)%#ok<MANU>


            icon={'Generic Playback'};
        end
    end

    methods(Static,Access=protected)

        function header=getHeaderImpl

            header=matlab.system.display.Header(mfilename("class"),...
            'Title','Generic block',...
            'Text','This block plays back the data from the recorded data file which is recorded on the hardware');
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
