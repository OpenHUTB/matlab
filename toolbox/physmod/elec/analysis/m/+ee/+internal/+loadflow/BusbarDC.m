classdef BusbarDC<ee.internal.loadflow.Block




    properties
        BlockType=getString(message('physmod:ee:loadflow:BusbarDC'));
        ComponentPath='ee.connectors.busbar_DC';
        Name='';
    end

    properties(Access=private)
        BusType='';
    end

    properties(Dependent)
RatedVoltage
VoltageMagnitude
    end

    methods
        function obj=BusbarDC(varargin)



            obj=obj@ee.internal.loadflow.Block(varargin{:});
        end

        function value=findPortNames(obj,blockName)
            value=cell(size(obj));
            for objIdx=1:length(obj)
                thisObj=obj(objIdx);

                switch get_param(thisObj.Name,'n_nodes')
                case 'ee.enum.connectors.busbar_number_of_connections.one'
                    portOrder={'LConn1','LConn2'};
                    portName={'p1','n1'};
                case 'ee.enum.connectors.busbar_number_of_connections.two'
                    portOrder={'LConn1','LConn2','RConn1','RConn2'};
                    portName={'p1','n1','p2','n2'};
                case 'ee.enum.connectors.busbar_number_of_connections.three'
                    portOrder={'LConn1','LConn2','RConn1','RConn2','LConn3','LConn4'};
                    portName={'p1','n1','p2','n2','p3','n3'};
                case 'ee.enum.connectors.busbar_number_of_connections.four'
                    portOrder={'LConn1','LConn2','RConn1','RConn2','LConn3','LConn4','RConn3','RConn4'};
                    portName={'p1','n1','p2','n2','p3','n3','p4','n4'};
                otherwise
                    error(message('physmod:ee:loadflow:BusbarNumberOfConnections'));
                end
                for portIdx=1:length(portOrder)
                    thisPort=portOrder{portIdx};
                    connectedBlocks=ee.internal.graph.findConnectedPhysicalBlocks(thisObj.Name,thisPort);
                    if any(strcmp(blockName,connectedBlocks))
                        value{objIdx}=[value{objIdx},portName(portIdx)];
                    end
                end
            end
        end

        function value=get.RatedVoltage(obj)

            value=obj.getValue('VRated','kV');
        end

        function value=get.VoltageMagnitude(obj)

            value=obj.getSimulationDataAtTime('Vt','1');
        end

        function value=getBusbarTable(obj)
            nObj=size(obj,1);
            realPowerFlows=obj.getRealPowerFlows;
            maxWidthPowerFlows=4;
            nanPadding=repmat({nan},nObj,maxWidthPowerFlows-width(realPowerFlows));
            realPowerFlows=[num2cell(realPowerFlows),nanPadding];

            nanCell=repmat({nan},1,nObj);
            tabledata={...
            'Block Type',obj.BlockType;...
            'Rated Voltage, kV',obj.RatedVoltage;...
            'Voltage Magnitude, pu',obj.VoltageMagnitude;...
            'Voltage Angle, deg',nanCell{:};...
            'Real Power Flow P1, MW',realPowerFlows{:,1};...
            'Reactive Power Flow Q1, MW',nanCell{:};...
            'Real Power Flow P2, MW',realPowerFlows{:,2};...
            'Reactive Power Flow Q2, MW',nanCell{:};...
            'Real Power Flow P3, MW',realPowerFlows{:,3};...
            'Reactive Power Flow Q3, MW',nanCell{:};...
            'Real Power Flow P4, MW',realPowerFlows{:,4};...
            'Reactive Power Flow Q4, MW',nanCell{:};...
            };
            value=cell2table(tabledata(:,2:end)',...
            'RowNames',{obj.Name},...
            'VariableNames',tabledata(:,1)');
        end

        function value=getBusbarTableInputMask(obj)
            nObj=size(obj,1);
            value=false(nObj,12);

            value(:,2)=true;
        end

        function value=getReactivePowerFlows(obj)
            for busbarIdx=1:length(obj)
                thisBusbar=obj(busbarIdx);
                switch get_param(thisBusbar.Name,'n_nodes')
                case 'ee.enum.connectors.busbar_number_of_connections.one'
                    value(busbarIdx,1)=nan;%#ok<AGROW>
                case 'ee.enum.connectors.busbar_number_of_connections.two'
                    value(busbarIdx,1:2)=[nan,nan];%#ok<AGROW>
                case 'ee.enum.connectors.busbar_number_of_connections.three'
                    value(busbarIdx,1:3)=[nan,nan,nan];%#ok<AGROW>
                case 'ee.enum.connectors.busbar_number_of_connections.four'
                    value(busbarIdx,1:4)=[nan,nan,nan,nan];%#ok<AGROW>
                end
            end
        end

        function value=getRealPowerFlows(obj)

            for busbarIdx=1:length(obj)
                thisBusbar=obj(busbarIdx);
                switch get_param(thisBusbar.Name,'n_nodes')
                case 'ee.enum.connectors.busbar_number_of_connections.one'
                    value(busbarIdx,1)=nan;%#ok<AGROW>
                otherwise
                    simulationDataAtTime=thisBusbar.getSimulationDataAtTime('P','MW');
                    value(busbarIdx,1:size(simulationDataAtTime,2))=simulationDataAtTime;%#ok<AGROW>
                end
            end
        end

        function value=getTableInputMask(obj)
            nObj=size(obj,1);
            value=false(nObj,14);

            value(:,3)=true;
        end

        function set.RatedVoltage(obj,value)
            obj.setValue('VRated',value,'kV');
        end

        function value=table(obj)
            nObj=size(obj,1);
            nanCell=repmat({nan},1,nObj);
            zeroCell=repmat({0},1,nObj);
            tabledata={...
            'Block Type',obj.BlockType;...
            'Bus Type',obj.BusType;...
            'Rated Voltage, kV',obj.RatedVoltage;...
            'Specified Voltage Magnitude, pu',nanCell{:};...
            'Actual Voltage Magnitude, pu',obj.VoltageMagnitude;...
            'Voltage Angle, deg',nanCell{:};...
            'Specified Generation P, MW',zeroCell{:};...
            'Actual Generation P, MW',zeroCell{:};...
            'Actual Generation Q, Mvar',zeroCell{:};...
            'Specified Demand P, MW',zeroCell{:};...
            'Actual Demand P, MW',zeroCell{:};...
            'Specified Demand Ql, Mvar',zeroCell{:};...
            'Specified Demand Qc, Mvar',zeroCell{:};...
            'Actual Demand Q, Mvar',zeroCell{:};...
            };
            value=cell2table(tabledata(:,2:end)',...
            'RowNames',{obj.Name},...
            'VariableNames',tabledata(:,1)');
        end
    end
end

