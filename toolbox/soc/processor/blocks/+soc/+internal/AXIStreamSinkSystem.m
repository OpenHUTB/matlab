classdef AXIStreamSinkSystem<ioplayback.SinkSystem
%#codegen



    properties(Nontunable)



        SampleTime=0.1;




        SamplesPerFrame=1024;




        dataTypeStr='unit32';
        DataTypeWarningasError=0;
    end
    methods
        function obj=AXIStreamSinkSystem(varargin)
            coder.allowpcode('plain');
            setProperties(obj,nargin,varargin{:});
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
        function updateProperties(obj,varargin)
            setProperties(obj,nargin-1,varargin{:});
        end
    end


    methods(Hidden,Access=protected)
        function checkDataFile(~,~)
        end
        function setupImpl(obj,varargin)
            if isempty(coder.target)
                obj.DataFileFormat='TimeStamp';
                obj.SignalInfo.Name='AXIStreamSinkSystem';
                obj.SignalInfo.Dimensions=[obj.SamplesPerFrame,1];
                obj.SignalInfo.DataType=obj.dataTypeStr;
                obj.SignalInfo.IsComplex=false;
                setupImpl@ioplayback.SinkSystem(obj,varargin{1});
            end
        end
    end

    methods(Static)
        function[groups,PropertyList]=getPGL
            [groups,PropertyList]=ioplayback.SinkSystem.getPropertyGroupsList();
        end
    end
end
