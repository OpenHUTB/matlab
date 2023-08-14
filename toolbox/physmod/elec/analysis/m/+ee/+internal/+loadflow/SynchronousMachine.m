classdef SynchronousMachine<ee.internal.loadflow.Block




    properties
        BlockType=getString(message('physmod:ee:loadflow:SynchronousMachine'));
        ComponentPath={'ee.electromech.sync.model_2_1.abc';...
        'ee.electromech.sync.round_rotor.abc';...
        'ee.electromech.sync.salient_pole.abc'};
        Name='';
    end

    properties(Dependent)
ActualDemandReactivePower
ActualDemandRealPower
ActualGenerationReactivePower
ActualGenerationRealPower
ActualVoltageMagnitude
BusType
IsDemandReactivePowerInput
IsDemandRealPowerInput
IsGenerationRealPowerInput
IsVoltageMagnitudeInput
RatedVoltage
SpecifiedDemandReactivePowerCapacitive
SpecifiedDemandReactivePowerInductive
SpecifiedDemandRealPower
SpecifiedGenerationRealPower
SpecifiedVoltageMagnitude
VoltageAngle
    end

    methods
        function obj=SynchronousMachine(varargin)



            obj=obj@ee.internal.loadflow.Block(varargin{:});
        end

        function value=get.ActualDemandReactivePower(obj)

            if strcmp(obj.BusType,'PQ')
                value=-1*obj.getAttachedBusbarValue('RConn2','ReactivePower');
            else
                value=0;
            end
        end

        function value=get.ActualDemandRealPower(obj)

            if strcmp(obj.BusType,'PQ')
                value=-1*obj.getAttachedBusbarValue('RConn2','RealPower');
            else
                value=0;
            end
        end

        function value=get.ActualGenerationReactivePower(obj)

            if~strcmp(obj.BusType,'PQ')
                value=obj.getAttachedBusbarValue('RConn2','ReactivePower');
            else
                value=0;
            end
        end

        function value=get.ActualGenerationRealPower(obj)

            if~strcmp(obj.BusType,'PQ')
                value=obj.getAttachedBusbarValue('RConn2','RealPower');
            else
                value=0;
            end
        end

        function value=get.ActualVoltageMagnitude(obj)
            value=obj.getAttachedBusbarValue('RConn2','VoltageMagnitude');
        end

        function value=get.BusType(obj)

            if obj.isVisible('source_type')
                busType=get_param(obj.Name,'source_type');
                value=strrep(busType,'ee.enum.sm.load_flow_source_type.','');
            else
                value='';
            end
        end

        function value=get.IsDemandReactivePowerInput(obj)
            if strcmp(obj.BusType,'PQ')
                value=true;
            else
                value=false;
            end
        end

        function value=get.IsDemandRealPowerInput(obj)
            if strcmp(obj.BusType,'PQ')
                value=true;
            else
                value=false;
            end
        end



        function value=get.IsGenerationRealPowerInput(obj)
            if strcmp(obj.BusType,'PV')
                value=true;
            else
                value=false;
            end
        end

        function value=get.IsVoltageMagnitudeInput(obj)
            value=obj.isVisible('Vmag0');
        end

        function value=get.RatedVoltage(obj)

            value=obj.getValue('VRated','kV');
        end

        function value=get.SpecifiedDemandReactivePowerCapacitive(obj)
            if strcmp(obj.BusType,'PQ')
                value=-1*obj.getValue('Qt0','V*A')/1e6;
                if value>0
                    value=0;
                end
            else
                value=0;
            end
        end

        function value=get.SpecifiedDemandReactivePowerInductive(obj)
            if strcmp(obj.BusType,'PQ')
                value=-1*obj.getValue('Qt0','V*A')/1e6;
                if value<0
                    value=0;
                end
            else
                value=0;
            end
        end

        function value=get.SpecifiedDemandRealPower(obj)
            if strcmp(obj.BusType,'PQ')
                value=-1*obj.getValue('Pt0','MW');
            else
                value=0;
            end
        end

        function value=get.SpecifiedGenerationRealPower(obj)
            if~strcmp(obj.BusType,'PQ')
                value=obj.getValue('Pt0','MW');
            else
                value=0;
            end
        end

        function value=get.SpecifiedVoltageMagnitude(obj)
            value=obj.getValue('Vmag0','kV')./obj.RatedVoltage;
        end

        function value=get.VoltageAngle(obj)

            isFrequencyVariable=true;
            value=obj.getSimulationDataAtTime('V','deg',isFrequencyVariable);
            value=value(1);
        end

        function value=getTableInputMask(obj)
            nObj=size(obj,1);
            value=false(nObj,14);

            value(:,2:3)=true;

            value(:,4)=[obj.IsVoltageMagnitudeInput]';


            value(:,7)=[obj.IsGenerationRealPowerInput]';

            value(:,10)=[obj.IsDemandRealPowerInput]';

            value(:,12)=[obj.IsDemandReactivePowerInput]';

            value(:,13)=[obj.IsDemandReactivePowerInput]';
        end

        function set.BusType(obj,value)
            if iscategorical(value)
                value=char(value);
            end



            mc=metaclass(ee.enum.sm.load_flow_source_type.Swing);
            if any(strcmp(value,{mc.EnumerationMemberList.Name}))
                value=[mc.Name,'.',value];
                set_param(obj.Name,'source_type',value);
            end
        end

        function set.RatedVoltage(obj,value)
            obj.setValue('VRated',value,'kV');
        end

        function set.SpecifiedDemandReactivePowerCapacitive(obj,value)
            obj.setValue('Qt0',-1*value*1e6,'V*A');
        end

        function set.SpecifiedDemandReactivePowerInductive(obj,value)
            obj.setValue('Qt0',-1*value*1e6,'V*A');
        end

        function set.SpecifiedDemandRealPower(obj,value)
            obj.setValue('Pt0',-1*value,'MW');
        end

        function set.SpecifiedGenerationRealPower(obj,value)
            obj.setValue('Pt0',value,'MW');
        end

        function set.SpecifiedVoltageMagnitude(obj,value)
            obj.setValue('Vmag0',value.*obj.RatedVoltage,'kV');
        end

        function value=table(obj)
            tabledata={...
            'Block Type',obj.BlockType;...
            'Bus Type',obj.BusType;...
            'Rated Voltage, kV',obj.RatedVoltage;...
            'Specified Voltage Magnitude, pu',obj.SpecifiedVoltageMagnitude;
            'Actual Voltage Magnitude, pu',obj.ActualVoltageMagnitude;
            'Voltage Angle, deg',obj.VoltageAngle;
            'Specified Generation P, MW',obj.SpecifiedGenerationRealPower;
            'Actual Generation P, MW',obj.ActualGenerationRealPower;
            'Actual Generation Q, Mvar',obj.ActualGenerationReactivePower;
            'Specified Demand P, MW',obj.SpecifiedDemandRealPower;
            'Actual Demand P, MW',obj.ActualDemandRealPower;
            'Specified Demand Ql, Mvar',obj.SpecifiedDemandReactivePowerInductive;...
            'Specified Demand Qc, Mvar',obj.SpecifiedDemandReactivePowerCapacitive;...
            'Actual Demand Q, Mvar',obj.ActualDemandReactivePower;...
            };
            value=cell2table(tabledata(:,2:end)',...
            'RowNames',{obj.Name},...
            'VariableNames',tabledata(:,1)');
        end
    end
end
