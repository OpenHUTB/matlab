classdef AXIStreamSourceSystem<ioplayback.SourceSystem
%#codegen



    properties(Nontunable)



        SampleTime=0.1;




        SamplesPerFrame=1024;




        dataTypeStr='unit32';
    end
    properties(Access=private)
EventTick
    end
    methods
        function obj=AXIStreamSourceSystem(varargin)
            coder.allowpcode('plain');
            setProperties(obj,nargin,varargin{:});
            obj.DataTypeWarningasError=0;
        end

        function y=readData(obj,ds)
            y=0;
            if isempty(coder.target)
                if nargin<2
                    ds=RecordedData(obj.DatasetName);
                end
                dataFile=getDataFile(ds,obj.SourceName);
                fid=fopen(dataFile,'r');
                if fid>0
                    y=fread(fid,Inf,['*',obj.dataTypeStr]);
                    fclose(fid);
                end

                ys=length(y);
                te=(ys/double(obj.SamplesPerFrame))*obj.SampleTime;
                y=timeseries(y,linspace(0,te,ys));
            end
        end
        function event=getNextEvent(obj,eventID,~)
            if isequal(obj.SimulationOutput,'From input port')||isequal(obj.SimulationOutput,'Zeros')

                event=[];
                return;
            else

                event.ID=eventID;
                if obj.SampleTime>0

                    event.Time=obj.SampleTime*obj.EventTick;
                else



                    ts=readTimestamp(obj.Reader);
                    if isempty(ts)
                        event=[];
                    else
                        event.Time=ts;
                    end
                end
                obj.EventTick=obj.EventTick+1;
            end
        end

        function checkDataFile(obj,dataFile)%#ok<INUSD>
            if isempty(coder.target)





            end
        end

        function updateProperties(obj,varargin)
            setProperties(obj,nargin-1,varargin{:});
        end

    end
    methods(Hidden,Access=protected)
        function setupImpl(obj,varargin)
            obj.EventTick=0;
            if isempty(coder.target)

                if isequal(obj.SimulationOutput,'From input port')
                    validateattributes(varargin{1},{obj.dataTypeStr},...
                    {'size',[obj.SamplesPerFrame,1]},'AXIRead','input');
                else
                    obj.DataFileFormat='TimeStamp';
                    obj.SignalInfo.Name='AXI4_IIO_Stream';
                    obj.SignalInfo.Dimensions=[obj.SamplesPerFrame,1];
                    obj.SignalInfo.DataType=obj.dataTypeStr;
                    obj.SignalInfo.IsComplex=false;
                    setupImpl@ioplayback.SourceSystem(obj);
                    if isequal(obj.SimulationOutput,'From recorded file')
                        setup(obj.Reader,1);
                    end
                end
            end
        end
    end
    methods(Static)
        function[groups,PropertyList]=getPGL
            [groups,PropertyList]=ioplayback.SourceSystem.getPropertyGroupsList();
        end
    end
end
