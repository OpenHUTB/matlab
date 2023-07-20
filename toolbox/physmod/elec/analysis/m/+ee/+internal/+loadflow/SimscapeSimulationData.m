classdef SimscapeSimulationData<ee.internal.loadflow.Super




    properties(Dependent)
Name
ModelName
IsAvailable
IsEnabled
    end

    properties(Access=private)
Model
Map
        ListenerHandles=event.listener.empty;
    end

    events
ValueChanged
    end

    methods
        function obj=SimscapeSimulationData(varargin)

            if nargin==1&&isa(varargin{1},'ee.internal.loadflow.Model')
                model=varargin{1};
            elseif nargin==1&&ischar(varargin{1})&&bdIsLoaded(strtok(varargin{1},'/'))
                modelName=bdroot(varargin{1});

                model=ee.internal.loadflow.Model(modelName);
            else
                obj=ee.internal.loadflow.SimscapeSimulationData.empty;
                return
            end
            obj.Model=model;


            obj.update;


            internalObject=get_param(obj.Model.Name,'InternalObject');
            obj.ListenerHandles(1)=listener(internalObject,'EngineSimulationEnd',@(source,event)obj.update(source,event));
        end

        function tf=get.IsAvailable(obj)

            baseVariableName=strtok(obj.Name,'.');
            tf=evalin('base',['exist(''',baseVariableName,''',''var'');']);
            if tf
                simlog=evalin('base',baseVariableName);
                if~isa(simlog,'simscape.logging.Node')
                    tf=false;
                end
            end
        end

        function tf=get.IsEnabled(obj)

            if bdIsLoaded(obj.Model.Name)
                ssc_get_configset=ssc_private('ssc_get_configset');
                configSet=ssc_get_configset(obj.Model.Name);
                simscapeLogType=get_param(configSet,'SimscapeLogType');
                tf=~strcmp(simscapeLogType,'none');
            else
                tf=false;
            end
        end

        function value=get.ModelName(obj)
            if bdIsLoaded(obj.Model.Name)
                value=obj.Model.Name;
            else
                value='';
            end
        end

        function value=get.Name(obj)
            if bdIsLoaded(obj.Model.Name)
                simscapeLogName=get_param(obj.Model.Name,'SimscapeLogName');
                returnWorkspaceOutputs=get_param(obj.Model.Name,'ReturnWorkspaceOutputs');
                if strcmp(returnWorkspaceOutputs,'off')

                    value=simscapeLogName;
                else

                    returnWorkSpaceOutputsName=get_param(obj.Model.Name,'ReturnWorkspaceOutputsName');
                    value=[returnWorkSpaceOutputsName,'.',simscapeLogName];
                end
            else
                value='';
            end
        end

        function value=getSimulationData(obj,blockpath)
            if obj.IsEnabled&&obj.IsAvailable
                simlog=evalin('base',obj.Name);
                if~exist('blockpath','var')
                    blockpath=obj.Model.Name;
                end
                if~obj.Map.isKey(blockpath)
                    obj.Map(blockpath)=simscape.logging.findNode(simlog,blockpath);
                end
                value=obj.Map(blockpath);
            else
                value=simscape.logging.Node.empty;
            end
        end

        function value=getSimulationDataAtTime(obj,blockpath,simulationTime,variablename,variableunit,isFrequencyVariable)
            simulationData=obj.getSimulationData(blockpath);
            if isempty(simulationData)
                value=nan;
            else
                if exist('isFrequencyVariable','var')&&isFrequencyVariable==true
                    if simulationData.V.isFrequency
                        time=simulationData.(variablename).phase.series.time;
                        values=simulationData.(variablename).phase.series.values(variableunit);
                    else
                        value=nan;
                        return
                    end
                else
                    time=simulationData.(variablename).series.time;
                    values=simulationData.(variablename).series.values(variableunit);
                end
                if length(time)>1
                    value=interp1(time,values,simulationTime,'linear',nan);
                elseif time==simulationTime
                    value=values;
                else
                    value=nan;
                end
            end
        end

        function set.IsEnabled(obj,tf)


            if tf
                simscapeLogType=get_param(obj.Model.Name,'SimscapeLogType');
                switch simscapeLogType
                case 'all'

                case 'local'

                    obj.Model.setLocalLogging(true);
                case 'none'

                    set_param(obj.Model.Name,'SimscapeLogType','local');
                    obj.Model.setLocalLogging(true);
                otherwise
                    warning('SimcapeLogType set to unknown value');
                end
            else
                set_param(obj.Model.Name,'SimscapeLogType','none');
            end
        end

        function update(obj,~,~)
            if obj.IsEnabled&&obj.IsAvailable
                obj.Map=containers.Map;
                notify(obj,'ValueChanged');
            end
        end
    end
end
