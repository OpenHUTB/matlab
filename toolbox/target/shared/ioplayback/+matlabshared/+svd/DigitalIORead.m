


classdef DigitalIORead<ioplayback.internal.BlockSampleTime



%#codegen
%#ok<*EMCA>


    properties(Nontunable)



        Pin='';

    end
    properties(Nontunable,Access=private,Hidden)
        DataLength=uint32(1);
        TypeByteLength=uint32(1);

        DataType='uint8';
        OutputDataType='uint8';
    end

    methods
        function obj=DigitalIORead(varargin)
            coder.allowpcode('plain');
            obj.DataFileFormat='TimeStamp';
            obj.SignalInfo=ioplayback.internal.SignalInfo('Name','DIORead','Dimensions',[1,1],'DataType',obj.DataType,'IsComplex',false);
            setProperties(obj,nargin,varargin{:});
            obj.DataTypeWarningasError=0;
        end
    end

    methods(Access=protected)
        function setupImpl(obj)
            obj.SignalInfo.DataType=obj.DataType;
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
                data_out=zeros([obj.SignalInfo.Dimensions(1),1],obj.SignalInfo.DataType);
            end
        end

        function releaseImpl(obj)
            if isempty(coder.target)
                releaseImpl@ioplayback.SourceSystem(obj);
            else

            end
        end

        function num=getNumOutputsImpl(obj)


            num=numel(obj.SignalInfo);

        end
        function[varargout]=isOutputFixedSizeImpl(~)

            varargout{1}=true;

        end

        function[varargout]=getOutputDataTypeImpl(~)


            varargout{1}='uint8';
        end

        function[varargout]=isOutputComplexImpl(~)

            varargout{1}=false;

        end

        function[varargout]=getOutputSizeImpl(obj)
            for i=1:numel(obj.SignalInfo)
                varargout{i}=[prod(obj.SignalInfo(i).Dimensions),1];
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
            configurePin(hwObjHandle,obj.Pin,'DigitalInput');
        end

        function configStreaming(obj,hwObjHandle)
            readDigitalPin(hwObjHandle,obj.Pin);
            setRate(hwObjHandle,obj.SampleTime);
        end

        function checkDataFile(~,~)

        end
    end
end

