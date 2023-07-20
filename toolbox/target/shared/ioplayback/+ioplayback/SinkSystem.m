classdef SinkSystem<ioplayback.System



%#codegen
    properties(Nontunable)

        SendSimulationInputTo='Terminator'
    end

    properties(Nontunable,Hidden)
        DataFileFormat='Raw'
        SignalInfo=ioplayback.internal.SignalInfo;



        SourceOverwriteWarningAsError(1,1)logical=false;
    end

    properties(Constant,Hidden)
        SendSimulationInputToSet=matlab.system.StringSet(...
        {'Terminator',...
        'Data file',...
        'Output port'})

        DataFileFormatSet=matlab.system.StringSet({'Raw',...
        'Raw-TimeStamp','Wave','TimeStamp','custom'})
    end

    methods

        function obj=SinkSystem(varargin)
            coder.allowpcode('plain');
            setProperties(obj,nargin,varargin{:});
        end
    end

    methods(Access=protected)
        function setupImpl(obj,varargin)
            if isequal(obj.SendSimulationInputTo,'Data file')
                if isequal(obj.DataFileFormat,'Raw-TimeStamp')||isequal(obj.DataFileFormat,'Raw')||isequal(obj.DataFileFormat,'TimeStamp')
                    SampleTime=get_param(gcb,'CompiledSampleTime');
                    current_system=bdroot(gcs);
                    recordDuration=get_param(current_system,'StopTime');
                    sysObj=obj;
                    obj.Writer=ioplayback.util.Writer('Filename',[tempname,'.bin'],...
                    'DataFileFormat',obj.DataFileFormat,...
                    'SampleTime',(SampleTime(1)/1000),...
                    'RecordDuration',str2double(recordDuration),...
                    'SinkObj',sysObj);
                elseif isequal(obj.DataFileFormat,'Wave')
                    obj.Writer=dsp.AudioFileWriter(...
                    'Filename',[tempname,'.wav'],...
                    'SampleRate',obj.SampleRate,...
                    'DataType',obj.SignalInfo.DataType);
                end
            end
        end

        function stepImpl(obj,varargin)
            if nargin>2
                sysObj=varargin{2};
            else
                sysObj=obj;
            end
            if isequal(obj.SendSimulationInputTo,'Data file')
                if obj.DataFileFormat=="Raw-TimeStamp"||obj.DataFileFormat=="TimeStamp"
                    step(obj.Writer,varargin{1},getCurrentTime(sysObj));
                elseif isequal(obj.DataFileFormat,'Raw')
                    step(obj.Writer,varargin{1});
                else
                    step(obj.Writer,varargin{1});
                end
            end
        end

        function releaseImpl(obj)
            if isequal(obj.SendSimulationInputTo,'Data file')&&...
                exist(obj.Writer.Filename,'file')
                try %#ok<EMTC>
                    ds=RecordedData(obj.DatasetName);
                catch
                    ds=RecordedData;
                end
                try %#ok<EMTC>
                    if obj.SourceOverwriteWarningAsError

                        addDataSource(ds,obj,obj.SourceName,obj.Writer.Filename);
                    else
                        if isDataSourcePresent(ds,obj.SourceName)

                            warning(message('ioplayback:utils:RepeatSourceNameWarn',obj.SourceName));
                            addDataSourceAtIndex(ds,obj,obj.SourceName,obj.Writer.Filename,isDataSourcePresent(ds,obj.SourceName));
                        else
                            addDataSource(ds,obj,obj.SourceName,obj.Writer.Filename);
                        end
                    end

                    release(obj.Writer);
                catch exc

                    release(obj.Writer);
                    rethrow(exc);
                end
                save(ds,obj.DatasetName);
            end
        end

        function N=getNumOutputsImpl(~)
            N=0;
        end

        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            if~isequal(obj.SendSimulationInputTo,'Data file')
                switch prop
                case{'DatasetName','SourceName'}
                    flag=true;
                end
            end
        end
    end

    methods(Static,Access=protected)
        function[groups,PropertyList]=getPropertyGroupsList


            SendSimulationInputToProp=matlab.system.display.internal.Property('SendSimulationInputTo','Description','Send simulation input to');

            DatasetNameProp=matlab.system.display.internal.Property('DatasetName','Description','Dataset name');

            SourceNameProp=matlab.system.display.internal.Property('SourceName','Description','Source name');



            PropertyListOut={SendSimulationInputToProp,DatasetNameProp,SourceNameProp};


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

