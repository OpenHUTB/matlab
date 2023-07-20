classdef SourceSystem<ioplayback.System



%#codegen
    properties(Nontunable)

        SimulationOutput='Zeros'
        DataTypeWarningasError=0;
    end

    properties(Nontunable,Hidden)
        DataFileFormat='Raw'

        SignalInfo=ioplayback.internal.SignalInfo;


    end

    properties(Access=protected)
        RecordedSampleTime=-1
    end

    properties(Constant,Hidden)
        SimulationOutputSet=matlab.system.StringSet(...
        {'Zeros',...
        'From recorded file',...
        'From input port'})

        DataFileFormatSet=matlab.system.StringSet({'Raw',...
        'Raw-TimeStamp','Wave','TimeStamp','custom'})
    end

    methods(Abstract,Hidden)
        checkDataFile(obj,dataFile);
    end

    methods

        function obj=SourceSystem(varargin)
            coder.allowpcode('plain');
            setProperties(obj,nargin,varargin{:});
        end
    end

    methods(Access=protected)
        function setupImpl(obj)
            if isequal(obj.SimulationOutput,'From recorded file')
                ds=RecordedData(obj.DatasetName);
                src=getDataSource(ds,obj.SourceName);

                dataFile=getDataFile(ds,obj.SourceName);

                if isfield(src.params,'NoOfSignals')&&~isequal(numel(obj.SignalInfo),src.params.NoOfSignals)
                    error(message('ioplayback:general:PortsMismatch',numel(obj.SignalInfo),src.params.NoOfSignals));
                end



                if isfield(src.params,'FileFormat')&&~isequal(obj.DataFileFormat,src.params.FileFormat)
                    error(message('ioplayback:general:FileFormatMismatch',obj.DataFileFormat,src.params.FileFormat));
                end

                if isequal(obj.SignalInfo(1).DataType,'boolean')
                    obj.SignalInfo(1).DataType='logical';
                else
                    obj.SignalInfo(1).DataType=obj.SignalInfo(1).DataType;
                end

                if~isequal(obj.SignalInfo(1).DataType,src.params.DataType)
                    if obj.DataTypeWarningasError
                        error(message('ioplayback:general:DataTypeMismatch',obj.SignalInfo(1).DataType,src.params.DataType));
                    else
                        warning(message('ioplayback:general:DataTypeMismatch',obj.SignalInfo(1).DataType,src.params.DataType));
                    end
                end

                if isequal(obj.DataFileFormat,'Wave')
                    obj.Reader=dsp.AudioFileReader('Filename',dataFile{2},...
                    'SamplesPerFrame',src.params.SamplesPerFrame,...
                    'OutputDataType',src.params.DataType);
                elseif isequal(obj.DataFileFormat,'TimeStamp')
                    obj.Reader=ioplayback.util.MultiPortReader('Filename',dataFile,'SignalInfo',obj.SignalInfo,'HWSignalInfo',src.params.HWSignalInfo,'HdrSize',src.HdrSize,'DataLen',src.params.DataLen,'PayloadSizeFieldLen',src.params.PayloadSizeFieldLen);

                end

                if isprop(src,'SampleTime')
                    obj.RecordedSampleTime=src.SampleTime;
                end
            end
        end

        function[data,varargout]=stepImpl(obj,varargin)
            if nargin<2
                portNumber=1;
            else
                portNumber=varargin{1};
            end
            if isequal(obj.SimulationOutput,'From recorded file')
                if isequal(obj.DataFileFormat,'TimeStamp')
                    [data,varargout{1}]=step(obj.Reader,portNumber);
                else
                    data=step(obj.Reader);
                end
            else
                data=zeros(prod(obj.SignalInfo(portNumber).Dimensions),1,obj.SignalInfo(portNumber).DataType);
            end
        end

        function releaseImpl(obj)
            if isequal(obj.SimulationOutput,'From recorded file')
                release(obj.Reader);
            end
        end


        function n=getNumInputsImpl(~)
            n=0;
        end

        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            if~isequal(obj.SimulationOutput,'From recorded file')
                switch prop
                case{'DatasetName','SourceName'}
                    flag=true;
                end
            end
        end
    end

    methods(Static,Access=protected)
        function[groups,PropertyList]=getPropertyGroupsList


            SimulationOutputProp=matlab.system.display.internal.Property('SimulationOutput','Description','Simulation output');

            DatasetNameProp=matlab.system.display.internal.Property('DatasetName','Description','Dataset name');

            SourceNameProp=matlab.system.display.internal.Property('SourceName','Description','Source name');



            PropertyListOut={SimulationOutputProp,DatasetNameProp,SourceNameProp};


            Group=matlab.system.display.SectionGroup(...
            'Title','Simulation',...
            'PropertyList',PropertyListOut);













            groups=Group;

            if nargout>1
                PropertyList=PropertyListOut;
            end
        end
    end
end

