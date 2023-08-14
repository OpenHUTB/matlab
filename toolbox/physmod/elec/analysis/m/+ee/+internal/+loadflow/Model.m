classdef Model<ee.internal.loadflow.Super




    properties
        Type='Model';
        Name='';
        SimulationConfiguration='Static';
        SimulationData=ee.internal.loadflow.SimscapeSimulationData.empty;
        SimulationTime=0;
        Error=false;
        Status=getString(message('physmod:ee:loadflow:StatusReady'));
        BlocksSelected=[];
ComponentPathMap
BlockFactoryMap
    end

    properties(Dependent)
Busbar
BusbarDC
ConnectionSizes
ConstantImpedanceLoad
InductionMachine
IsHighlighted
LoadFlowSource
NConnections
NNodes
NodeSizes
SolverConfiguration
SynchronousMachine
Transformer
TransmissionLine
    end

    properties(Access=private)
        xIsHighlighted=false;
        ListenerHandles=event.listener.empty;
    end

    events
StatusChanged
ValueChanged
    end

    methods
        function obj=Model(name)



            obj.Name=name;


            obj.SimulationData(1)=ee.internal.loadflow.SimscapeSimulationData(obj);


            internalObject=get_param(obj.Name,'InternalObject');
            obj.ListenerHandles(1)=listener(internalObject,'EngineCompFailed',@(source,event)obj.updateStatus(source,event));
            obj.ListenerHandles(end+1)=listener(internalObject,'EngineSimStatusInitializing',@(source,event)obj.updateStatus(source,event));
            obj.ListenerHandles(end+1)=listener(internalObject,'EngineSimulationStart',@(source,event)obj.updateStatus(source,event));
            obj.ListenerHandles(end+1)=listener(internalObject,'EngineSimStatusRunning',@(source,event)obj.updateStatus(source,event));
            obj.ListenerHandles(end+1)=listener(internalObject,'EngineSimStatusStopped',@(source,event)obj.updateStatus(source,event));
            obj.ListenerHandles(end+1)=listener(internalObject,'EngineSimulationEnd',@(source,event)obj.updateStatus(source,event));
            obj.ListenerHandles(end+1)=listener(internalObject,'SLGraphicalEvent::CLOSE_MODEL_EVENT',@(source,event)obj.updateStatus(source,event));


            obj.ListenerHandles(end+1)=listener(obj.SimulationData,'ValueChanged',@(source,event)obj.update(source,event));


            obj.update;
        end

        function value=get.Busbar(obj)
            value=ee.internal.loadflow.Busbar(obj);
        end

        function value=get.BusbarDC(obj)
            value=ee.internal.loadflow.BusbarDC(obj);
        end

        function value=get.ConnectionSizes(obj)
            nTransmissionLine=size(obj.TransmissionLine,1);
            nTransformer=size(obj.Transformer,1);
            value=[nTransmissionLine,nTransformer];
        end

        function value=get.ConstantImpedanceLoad(obj)
            value=ee.internal.loadflow.ConstantImpedanceLoad(obj);
        end

        function value=get.InductionMachine(obj)
            value=ee.internal.loadflow.InductionMachine(obj);
        end

        function value=get.IsHighlighted(obj)


            value=obj.xIsHighlighted;
        end

        function value=get.LoadFlowSource(obj)
            value=ee.internal.loadflow.LoadFlowSource(obj);
        end

        function value=get.NConnections(obj)
            value=sum(obj.ConnectionSizes);
        end

        function value=get.NNodes(obj)
            value=sum(obj.NodeSizes);
        end

        function value=get.NodeSizes(obj)
            nLoadFlowSource=size(obj.LoadFlowSource,1);
            nSynchronousMachine=size(obj.SynchronousMachine,1);
            nBusbar=size(obj.Busbar,1);
            nInductionMachine=size(obj.InductionMachine,1);
            nConstantImpedanceLoad=size(obj.ConstantImpedanceLoad,1);
            nBusbarDC=size(obj.BusbarDC,1);

            value=[nLoadFlowSource,nSynchronousMachine,nBusbar,...
            nInductionMachine,nConstantImpedanceLoad,nBusbarDC];
        end

        function value=get.SolverConfiguration(obj)
            if Simulink.internal.useFindSystemVariantsMatchFilter()
                solverConfigurations=find_system(obj.Name,...
                'LookUnderMasks','all',...
                'FollowLinks','on',...
                'MatchFilter',@Simulink.match.activeVariants,...
                'ReferenceBlock','nesl_utility/Solver Configuration');
            else
                solverConfigurations=find_system(obj.Name,...
                'LookUnderMasks','all',...
                'FollowLinks','on',...
                'Variants','ActiveVariants',...
                'ReferenceBlock','nesl_utility/Solver Configuration');
            end
            equationFormulation={};
            DoDC={};
            for idxSolverConfigurations=1:length(solverConfigurations)
                thisSolverConfiguration=solverConfigurations{idxSolverConfigurations};
                equationFormulation{idxSolverConfigurations}=get_param(thisSolverConfiguration,'EquationFormulation');%#ok<AGROW>
                DoDC{idxSolverConfigurations}=get_param(thisSolverConfiguration,'DoDC');%#ok<AGROW>
            end
            if all(strcmp('NE_FREQUENCY_TIME_EF',equationFormulation))&&all(strcmp('off',DoDC))
                value='FrequencyAndTime';
            elseif all(strcmp('NE_TIME_EF',equationFormulation))&&all(strcmp('on',DoDC))
                value='TimeAndSteadyState';
            else
                value='Local';
            end
        end

        function value=get.SynchronousMachine(obj)
            value=ee.internal.loadflow.SynchronousMachine(obj);
        end

        function value=get.Transformer(obj)
            value=ee.internal.loadflow.Transformer(obj);
        end

        function value=get.TransmissionLine(obj)
            value=ee.internal.loadflow.TransmissionLine(obj);
        end

        function value=getAcNodeBlockN(obj,blockIndex)



            nodeSizes=obj.NodeSizes;
            nLoadFlowSource=nodeSizes(1);
            nSynchronousMachine=nodeSizes(2);
            nBusbar=nodeSizes(3);
            nInductionMachine=nodeSizes(4);
            nConstantImpedanceLoad=nodeSizes(5);
            if blockIndex<=nLoadFlowSource
                value=obj.LoadFlowSource(blockIndex);
            elseif blockIndex<=(nLoadFlowSource+nSynchronousMachine)
                blockIndex=blockIndex-nLoadFlowSource;
                value=obj.SynchronousMachine(blockIndex);
            elseif blockIndex<=(nLoadFlowSource+nSynchronousMachine+nBusbar)
                blockIndex=blockIndex-nLoadFlowSource-nSynchronousMachine;
                value=obj.Busbar(blockIndex);
            elseif blockIndex<=(nLoadFlowSource+nSynchronousMachine+nBusbar+nInductionMachine)
                blockIndex=blockIndex-nLoadFlowSource-nSynchronousMachine-nBusbar;
                value=obj.InductionMachine(blockIndex);
            elseif blockIndex<=(nLoadFlowSource+nSynchronousMachine+nBusbar+nInductionMachine+nConstantImpedanceLoad)
                blockIndex=blockIndex-nLoadFlowSource-nSynchronousMachine-nBusbar-nInductionMachine;
                value=obj.ConstantImpedanceLoad(blockIndex);
            else
                error(message('physmod:ee:loadflow:BlockIndexTooHigh'));
            end
        end

        function value=getBusbarBlockN(obj,blockIndex)



            nodeSizes=obj.NodeSizes;
            nBusbar=nodeSizes(3);
            nBusbarDC=nodeSizes(6);
            if blockIndex<=nBusbar
                value=obj.Busbar(blockIndex);
            elseif blockIndex<=(nBusbar+nBusbarDC)
                blockIndex=blockIndex-nBusbar;
                value=obj.BusbarDC(blockIndex);
            else
                error(message('physmod:ee:loadflow:BlockIndexTooHigh'));
            end
        end

        function value=getBusbarTable(obj)
            try
                if isempty(obj.Busbar)

                    value=obj.BusbarDC.getBusbarTable;
                elseif isempty(obj.BusbarDC)

                    value=obj.Busbar.getBusbarTable;
                else
                    value=vertcat(obj.Busbar.getBusbarTable,...
                    obj.BusbarDC.getBusbarTable);
                end
            catch
                value=[];

                try
                    set_param(obj.Name,'SimulationCommand','Update');
                catch err

                    obj.Error=true;
                    obj.Status=getString(message('physmod:ee:loadflow:DiagnosticViewer'));
                    notify(obj,'StatusChanged');

                    sldiagviewer.createStage(getString(message('physmod:ee:loadflow:LoadFlowAnalyzer')),'ModelName',obj.Name);
                    sldiagviewer.reportError(err);
                end
            end
            if isempty(value)
                tabledata={...
                'Block Type','';...
                'Rated Voltage, kV','';...
                'Voltage Magnitude, pu','';...
                'Real Power Flow P1, MW','';...
                'Reactive Power Flow Q1, MW','';...
                'Real Power Flow P2, MW','';...
                'Reactive Power Flow Q2, MW','';...
                'Real Power Flow P3, MW','';...
                'Reactive Power Flow Q3, MW','';...
                'Real Power Flow P4, MW','';...
                'Reactive Power Flow Q4, MW','';...
                };
                value=cell2table(tabledata(:,2:end)',...
                'RowNames',{getString(message('physmod:ee:loadflow:NoLoadFlowBusbars'))},...
                'VariableNames',tabledata(:,1)');
            end
        end

        function value=getBusbarTableInputMask(obj)
            value=vertcat(obj.Busbar.getBusbarTableInputMask,...
            obj.BusbarDC.getBusbarTableInputMask);
        end

        function value=getNodeTable(obj)
            try
                value=vertcat(obj.LoadFlowSource.table,...
                obj.SynchronousMachine.table,...
                obj.Busbar.table,...
                obj.InductionMachine.table,...
                obj.ConstantImpedanceLoad.table);
            catch
                value=[];

                try
                    set_param(obj.Name,'SimulationCommand','Update');
                catch err

                    obj.Error=true;
                    obj.Status=getString(message('physmod:ee:loadflow:DiagnosticViewer'));
                    notify(obj,'StatusChanged');

                    sldiagviewer.createStage(getString(message('physmod:ee:loadflow:LoadFlowAnalyzer')),'ModelName',obj.Name);
                    sldiagviewer.reportError(err);
                end
            end


            if~isempty(value)
                valueSet={...
                'Time',...
                'Swing',...
                'PV',...
                'PQ',...
                'Z',...
                '',...
                };
                categoryNames={...
                'Time',...
                'Swing',...
                'PV',...
                'PQ',...
                'Z',...
                'None',...
                };
                value.("Bus Type")=categorical(value.("Bus Type"),valueSet,categoryNames);
            else
                tabledata={...
                'Block Type','';...
                'Bus Type','';...
                'Rated Voltage, kV','';...
                'Specified Voltage Magnitude, pu','';...
                'Actual Voltage Magnitude, pu','';...
                'Voltage Angle, deg','';...
                'Specified Generation P, MW','';...
                'Actual Generation P, MW','';...
                'Actual Generation Q, Mvar','';...
                'Specified Demand P, MW','';...
                'Actual Demand P, MW','';...
                'Specified Demand Ql, Mvar','';...
                'Specified Demand Qc, Mvar','';...
                'Actual Demand Q, Mvar','';...
                };
                value=cell2table(tabledata(:,2:end)',...
                'RowNames',{getString(message('physmod:ee:loadflow:NoLoadFlowNodes'))},...
                'VariableNames',tabledata(:,1)');
            end
        end

        function value=getConnectionTable(obj)
            try
                value=vertcat(obj.TransmissionLine.table,...
                obj.Transformer.table);
            catch
                value=[];

                try
                    set_param(obj.Name,'SimulationCommand','Update');
                catch err

                    obj.Error=true;
                    obj.Status=getString(message('physmod:ee:loadflow:DiagnosticViewer'));
                    notify(obj,'StatusChanged');

                    sldiagviewer.createStage(getString(message('physmod:ee:loadflow:LoadFlowAnalyzer')),'ModelName',obj.Name);
                    sldiagviewer.reportError(err);
                end
            end
            if isempty(value)
                tabledata={...
                'Block Type','';...
                'From Busbar','';...
                'To Busbar','';...
                'Rated Voltage, kV','';...
                'Voltage V1, pu','';...
                'Voltage V2, pu','';...
                'Voltage Angle12, deg','';...
                'Real Power Flow P12, MW','';...
                'Reactive Power Flow Q12, Mvar','';...
                'Real Power Flow P21, MW','';...
                'Reactive Power Flow Q21, Mvar','';...
                'Real Power Loss, MW','';...
                'Reactive power Loss, Mvar','';...
                };
                value=cell2table(tabledata(:,2:end)',...
                'RowNames',{getString(message('physmod:ee:loadflow:NoLoadFlowConnections'))},...
                'VariableNames',tabledata(:,1)');
            end
        end

        function value=getSimulationData(obj,simtime)
            if~exist('simtime','var')
                simtime=0;
            end
            value=obj.SimulationData.getSimulationData(simtime);
        end

        function value=getSimulationLimits(obj)
            startTime=str2double(get_param(obj.Name,'StartTime'));
            stopTime=str2double(get_param(obj.Name,'StopTime'));
            value=[startTime,stopTime];
        end

        function value=getTableInputMask(obj)
            value=vertcat(obj.LoadFlowSource.getTableInputMask,...
            obj.SynchronousMachine.getTableInputMask,...
            obj.Busbar.getTableInputMask,...
            obj.InductionMachine.getTableInputMask,...
            obj.ConstantImpedanceLoad.getTableInputMask);
        end

        function highlightBlocks(obj,blockNames)
            if exist('blockNames','var')

                obj.BlocksSelected=blockNames;
            else

                blockNames=obj.BlocksSelected;
            end
            if obj.IsHighlighted&&~isempty(blockNames)

                if~isempty(blockNames)
                    highlight_system(obj.Name,blockNames);
                end
            end
        end




















        function run(obj)
            if any(strcmp(get_param(obj.Name,'SimscapeLogType'),{'none','local'}))
                obj.setLocalLogging(true);
            end
            try
                switch obj.SimulationConfiguration
                case 'Static'
                    evalin('base',['sim(''',obj.Name,''',[0 0]);']);


                    obj.SimulationTime=0;
                case 'Dynamic'
                    evalin('base',['sim(''',obj.Name,''');']);
                end
            catch err

                obj.Error=true;
                obj.Status=getString(message('physmod:ee:loadflow:DiagnosticViewer'));
                notify(obj,'StatusChanged');

                sldiagviewer.createStage(getString(message('physmod:ee:loadflow:LoadFlowAnalyzer')),'ModelName',obj.Name);
                sldiagviewer.reportError(err);
            end
        end

        function runChecks(obj)



            if isempty(find_system(obj.Name,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Type','Block'))

                obj.Error=true;
                obj.Status=getString(message('physmod:ee:loadflow:AddLoadFlowBlocks'));
                notify(obj,'StatusChanged')
            elseif obj.NNodes==0&&obj.NConnections==0

                obj.Error=true;
                obj.Status=getString(message('physmod:ee:loadflow:AddLoadFlowBlocks'));
                notify(obj,'StatusChanged')





            end
        end

        function set.IsHighlighted(obj,value)
            if obj.xIsHighlighted~=value

                obj.xIsHighlighted=value;
                if value
                    obj.highlightBlocks();
                else
                    if bdIsLoaded(obj.Name)
                        attentionstyler=SLStudio.AttentionStyler;
                        attentionstyler.removeCurrentHighlight(obj.Name);
                    end
                end
            end
        end

        function setAcNodeBlockProperty(obj,indices,previousData,nextData)

            performUpdate=false;
            switch class(previousData)
            case 'categorical'
                if previousData~=nextData
                    performUpdate=true;
                end
            case 'double'
                if previousData~=nextData
                    performUpdate=true;
                end
            otherwise
            end

            rowIndex=indices(1);
            block=obj.getAcNodeBlockN(rowIndex);
            if performUpdate
                columnIndex=indices(2);
                switch columnIndex
                case 2
                    block.BusType=nextData;
                case 3
                    block.RatedVoltage=nextData;
                case 4
                    block.SpecifiedVoltageMagnitude=nextData;
                case 7
                    block.SpecifiedGenerationRealPower=nextData;
                case 10
                    block.SpecifiedDemandRealPower=nextData;
                case 12
                    block.SpecifiedDemandReactivePowerInductive=nextData;
                case 13
                    block.SpecifiedDemandReactivePowerCapacitive=nextData;
                otherwise
                end
            end
            obj.update;
        end

        function setBusbarBlockProperty(obj,indices,previousData,nextData)

            rowIndex=indices(1);
            block=obj.getBusbarBlockN(rowIndex);

            if previousData~=nextData
                columnIndex=indices(2);
                switch columnIndex
                case 2
                    block.RatedVoltage=nextData;
                otherwise
                end
            end
            obj.update;
        end

        function setLocalLogging(obj,tf)
            set_param(obj.Name,'SimscapeLogType','local');
            obj.Busbar.setLocalLogging(tf);
            obj.ConstantImpedanceLoad.setLocalLogging(tf);
            obj.InductionMachine.setLocalLogging(tf);
            obj.LoadFlowSource.setLocalLogging(tf);
            obj.SynchronousMachine.setLocalLogging(tf);
        end

        function set.SolverConfiguration(obj,value)
            if Simulink.internal.useFindSystemVariantsMatchFilter()
                solverConfigurations=find_system(obj.Name,...
                'LookUnderMasks','all',...
                'FollowLinks','on',...
                'MatchFilter',@Simulink.match.activeVariants,...
                'ReferenceBlock','nesl_utility/Solver Configuration');
            else
                solverConfigurations=find_system(obj.Name,...
                'LookUnderMasks','all',...
                'FollowLinks','on',...
                'Variants','ActiveVariants',...
                'ReferenceBlock','nesl_utility/Solver Configuration');
            end
            for idxSolverConfigurations=1:length(solverConfigurations)
                thisSolverConfiguration=solverConfigurations{idxSolverConfigurations};
                switch value
                case 'FrequencyAndTime'
                    set_param(thisSolverConfiguration,'EquationFormulation','NE_FREQUENCY_TIME_EF');
                    set_param(thisSolverConfiguration,'DoDC','off');
                case 'TimeAndSteadyState'
                    set_param(thisSolverConfiguration,'EquationFormulation','NE_TIME_EF');
                    set_param(thisSolverConfiguration,'DoDC','on');
                case 'Local'

                otherwise
                    error(message('physmod:ee:loadflow:SetSolverConfiguration'));
                end
            end
        end

        function update(obj,~,~)

            obj.Error=false;

            obj.Status=getString(message('physmod:ee:loadflow:StatusRefreshing'));
            notify(obj,'StatusChanged');

            obj.ComponentPathMap=containers.Map;
            obj.BlockFactoryMap=containers.Map;

            obj.runChecks;

            obj.SimulationData.update;
            notify(obj,'ValueChanged');

            if~obj.Error
                obj.Status=getString(message('physmod:ee:loadflow:StatusReady'));
                notify(obj,'StatusChanged');
            end
        end

        function updateStatus(obj,~,event)
            switch event.EventName
            case 'EngineCompFailed'
                obj.Error=true;
                obj.Status=getString(message('physmod:ee:loadflow:ModelUpdateError'));
            case 'EngineSimStatusInitializing'
                obj.Status=getString(message('physmod:ee:loadflow:StatusCompiling'));
            case 'EngineSimulationStart'
                obj.Status=getString(message('physmod:ee:loadflow:StatusInitializing'));
            case 'EngineSimStatusRunning'
                obj.Status=getString(message('physmod:ee:loadflow:StatusRunning'));
            case 'EngineSimStatusStopped'
                if obj.Error==false
                    obj.Status=getString(message('physmod:ee:loadflow:StatusReady'));
                end
            case 'EngineSimulationEnd'
                if obj.Error==false
                    obj.Status=getString(message('physmod:ee:loadflow:StatusRefreshing'));
                    obj.update;
                else

                    obj.update;

                    obj.Error=false;
                end
            case 'SLGraphicalEvent::CLOSE_MODEL_EVENT'
                if strcmp(event.Source.Name,obj.Name)
                    obj.Status=getString(message('physmod:ee:loadflow:StatusClosing'));
                end
            otherwise
                error(message('physmod:ee:loadflow:UnrecognizedEventName'));
            end
            notify(obj,'StatusChanged');
        end
    end
end

function highlight_system(modelname,blocks)
    attentionstyler=SLStudio.AttentionStyler;
    attentionstyler.removeCurrentHighlight(modelname);
    for blockIdx=1:length(blocks)
        blockName=[modelname,'/',blocks{blockIdx}];
        try
            attentionstyler.applyHighlight(get_param(blockName,'handle'));
            parentName=get_param(blockName,'parent');
            while~strcmp(parentName,modelname)
                attentionstyler.applyHighlight(get_param(parentName,'handle'));
                parentName=get_param(parentName,'parent');
            end
        catch

        end
    end
end
