classdef AnalogRead<ioplayback.internal.BlockSampleTime


%#codegen
%#ok<*EMCA>


    properties(Nontunable)

        Pin='';

    end

    properties(Nontunable,Access=private,Hidden)
        DataLength=uint32(1);
        TypeByteLength=uint32(1);

        DataType='uint16';
    end

    methods
        function obj=AnalogRead(varargin)
            coder.allowpcode('plain');
            setProperties(obj,nargin,varargin{:});
            obj.DataTypeWarningasError=0;
        end
    end

    methods(Access=protected)

        function setupImpl(obj)
            obj.SignalInfo=ioplayback.internal.SignalInfo('Name','AnalogRead','Dimensions',[1,1],'DataType',obj.DataType,'IsComplex',false);
            if isempty(coder.target)
                setupImpl@ioplayback.SourceSystem(obj);
                if isequal(obj.SimulationOutput,'From recorded file')
                    setup(obj.Reader,1);
                end
            else
            end
        end
        function data_out=stepImpl(obj,varargin)
            if isempty(coder.target)
                data_out=stepImpl@ioplayback.SourceSystem(obj);
            else
                data_out=zeros([obj.SignalInfo.Dimensions(1),obj.SignalInfo.Dimensions(2)],obj.SignalInfo.DataType);
            end
        end
        function releaseImpl(obj)
            if isempty(coder.target)
                releaseImpl@ioplayback.SourceSystem(obj);
            else

            end
        end

        function sts=getSampleTimeImpl(obj)
            sts=getSampleTimeImpl@ioplayback.internal.BlockSampleTime(obj);
        end
    end


    methods
        function set.Pin(obj,value)
            validateattributes(value,{'numeric','logical','char'},{'vector'},'','Pin');
            if ischar(value)
                value=upper(value);
            end
            obj.Pin=value;
        end
        function configSource(obj,hwObjHandle)
            configurePin(hwObjHandle,obj.Pin,'AnalogInput');
        end
        function configStreaming(obj,hwObjHandle)
            readVoltage(hwObjHandle,obj.Pin);
            setRate(hwObjHandle,obj.SampleTime);
        end

        function checkDataFile(obj,dataFile)

        end
    end
end

