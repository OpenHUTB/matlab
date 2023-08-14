classdef DesktopLoggingSpecificationImpl<Simulink.Simulation.internal.LoggingSpecificationImpl
    properties(SetAccess=private,GetAccess=public)
        SignalsToLog=Simulink.SimulationData.SignalLoggingInfo.empty()
    end

    methods
        function addSignalsToLog(obj,varargin)
            if nargin<2||nargin>3
                DAStudio.error('Simulink:Commands:LoggingSpecSignals');
            end
            if isequal(nargin,2)
                if isa(varargin{1},'Simulink.SimulationData.SignalLoggingInfo')
                    if isempty(varargin{1})
                        DAStudio.error('Simulink:Commands:LoggingSpecSignals');
                    else
                        sigs=varargin{1};
                    end
                elseif isa(varargin{1},'Simulink.BlockPath')||...
                    isa(varargin{1},'Simulink.SimulationData.BlockPath')||...
                    isa(varargin{1},'char')
                    sigs=Simulink.SimulationData.SignalLoggingInfo(...
                    varargin{1});
                else
                    DAStudio.error('Simulink:Commands:LoggingSpecSignals');
                end
                obj.SignalsToLog=[obj.SignalsToLog,sigs(:)'];
            else


                sigs=Simulink.SimulationData.SignalLoggingInfo(...
                varargin{1},varargin{2});
                obj.SignalsToLog=[obj.SignalsToLog,sigs];
            end
        end

        function removeSignalsToLog(obj,sigs)


            narginchk(2,2);
            if~isa(sigs,'Simulink.SimulationData.SignalLoggingInfo')||...
                isempty(sigs)
                DAStudio.error('Simulink:Commands:LoggingSpecSignals');
            end
            idxsToRemove=[];
            for idx=1:numel(sigs)
                for jdx=1:numel(obj.SignalsToLog)
                    if isequal(sigs(idx),obj.SignalsToLog(jdx))
                        idxsToRemove=[idxsToRemove,jdx];%#ok<AGROW>
                    end
                end
            end
            obj.SignalsToLog(idxsToRemove)=[];
        end
    end

    methods(Hidden=true)
        function dlo=getSignalsToLog(obj,ModelName)
            dlo=Simulink.SimulationData.ModelLoggingInfo(ModelName);
            signalsToLog=obj.getUniqueSignals();
            signalsToLog=arrayfun(@(x)x.cacheSSIDs(false),signalsToLog);
            signalsToLog=arrayfun(@(x)obj.setLoggingInfoProperties(x),signalsToLog);
            dlo.Signals=signalsToLog;
        end
    end

    methods(Access=private)
        function uniqueSignals=getUniqueSignals(obj)

            stringIdentifierCreator=@(sigInfo)string(sigInfo.BlockPath.toPipePath)+"("+sigInfo.OutputPortIndex+")";
            signalIdentifiers=arrayfun(@(sigInfo)stringIdentifierCreator(sigInfo),obj.SignalsToLog);
            [~,uniqueSignalsIdx,~]=unique(signalIdentifiers,'stable');
            uniqueSignals=obj.SignalsToLog(uniqueSignalsIdx);
        end
    end

    methods(Static,Access=private)
        function signalLoggingInfo=setLoggingInfoProperties(signalLoggingInfo)
            bPath=signalLoggingInfo.BlockPath.convertToCell;
            isValidBlockPath=getSimulinkBlockHandle(bPath{end})>0;

            if~isValidBlockPath
                return;
            end

            portHandles=get_param(bPath{end},'PortHandles');
            if signalLoggingInfo.OutputPortIndex>numel(portHandles.Outport)
                return;
            end

            ph=portHandles.Outport(signalLoggingInfo.OutputPortIndex);
            dataLoggingMaxPointsStr=get_param(ph,"DataLoggingMaxPoints");
            dataLoggingMaxPoints=str2double(dataLoggingMaxPointsStr);
            if~isnan(dataLoggingMaxPoints)
                signalLoggingInfo.LoggingInfo.MaxPoints=dataLoggingMaxPoints;
            end
            signalLoggingInfo.LoggingInfo.LimitDataPoints=logical(matlab.lang.OnOffSwitchState(...
            get_param(ph,"DataLoggingLimitDataPoints")));
        end
    end
end
