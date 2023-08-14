classdef ConstantImpedanceLoad<ee.internal.loadflow.Block




    properties
        BlockType=getString(message('physmod:ee:loadflow:ConstantImpedanceLoad'));
        ComponentPath={'ee.passive.rlc_assemblies.wye.abc';...
        'ee.passive.rlc_assemblies.delta.abc'};
        Name='';
    end

    properties(Access=private)
        BusType='Z';
    end

    properties(Dependent)
ActualDemandReactivePower
ActualDemandRealPower
ActualVoltageMagnitude
IsDemandReactivePowerInductiveInput
IsDemandReactivePowerCapacitiveInput
IsDemandRealPowerInput
RatedVoltage
SpecifiedDemandReactivePowerInductive
SpecifiedDemandReactivePowerCapacitive
SpecifiedDemandRealPower
VoltageAngle
    end

    methods
        function obj=ConstantImpedanceLoad(varargin)



            obj=obj@ee.internal.loadflow.Block(varargin{:});
        end

        function value=get.ActualDemandReactivePower(obj)

            value=-1*obj.getAttachedBusbarValue('LConn1','ReactivePower');
        end

        function value=get.ActualDemandRealPower(obj)


            value=-1*obj.getAttachedBusbarValue('LConn1','RealPower');
        end

        function value=get.ActualVoltageMagnitude(obj)

            value=obj.getAttachedBusbarValue('LConn1','VoltageMagnitude');
        end

        function value=get.IsDemandReactivePowerCapacitiveInput(obj)
            value=obj.isVisible('Qneg');
        end

        function value=get.IsDemandReactivePowerInductiveInput(obj)
            value=obj.isVisible('Qpos');
        end

        function value=get.IsDemandRealPowerInput(obj)
            value=obj.isVisible('P');
        end

        function value=get.RatedVoltage(obj)

            value=obj.getValue('VRated','kV');
        end

        function value=get.SpecifiedDemandReactivePowerCapacitive(obj)



            value=obj.getValue('Qneg','V*A')/1e6;
            if isnan(value)
                value=0;
            end
        end

        function value=get.SpecifiedDemandReactivePowerInductive(obj)



            value=obj.getValue('Qpos','V*A')/1e6;
            if isnan(value)
                value=0;
            end
        end

        function value=get.SpecifiedDemandRealPower(obj)

            value=obj.getValue('P','MW');
            if isnan(value)
                value=0;
            end
        end

        function value=get.VoltageAngle(obj)

            value=obj.getAttachedBusbarValue('LConn1','VoltageAngle');
        end

        function value=getTableInputMask(obj)
            nObj=size(obj,1);
            value=false(nObj,14);

            value(:,3)=true;

            value(:,10)=[obj.IsDemandRealPowerInput]';

            value(:,12)=[obj.IsDemandReactivePowerInductiveInput]';

            value(:,13)=[obj.IsDemandReactivePowerCapacitiveInput]';
        end

        function set.RatedVoltage(obj,value)
            obj.setValue('VRated',value,'kV');
        end

        function set.SpecifiedDemandReactivePowerCapacitive(obj,value)

            if value<0
                obj.setValue('Qneg',1e6*value,'V*A');
            end
        end

        function set.SpecifiedDemandReactivePowerInductive(obj,value)

            if value>0
                obj.setValue('Qpos',1e6*value,'V*A');
            end
        end

        function set.SpecifiedDemandRealPower(obj,value)
            if value>0
                obj.setValue('P',value,'MW');
            end
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
            'Actual Voltage Magnitude, pu',obj.ActualVoltageMagnitude;...
            'Voltage Angle, deg',obj.VoltageAngle;...
            'Specified Generation P, MW',zeroCell{:};...
            'Actual Generation P, MW',zeroCell{:};...
            'Actual Generation Q, Mvar',zeroCell{:};...
            'Specified Demand P, MW',obj.SpecifiedDemandRealPower;...
            'Actual Demand P, MW',obj.ActualDemandRealPower;...
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

