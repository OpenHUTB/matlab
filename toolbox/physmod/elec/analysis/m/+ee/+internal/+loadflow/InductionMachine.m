classdef InductionMachine<ee.internal.loadflow.Block




    properties
        BlockType=getString(message('physmod:ee:loadflow:InductionMachine'));
        ComponentPath={'ee.electromech.async.squirrel_cage.abc';...
        'ee.electromech.async.wound_rotor.abc';};
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
        function obj=InductionMachine(varargin)



            obj=obj@ee.internal.loadflow.Block(varargin{:});
        end

        function value=get.ActualDemandReactivePower(obj)
            if strcmp('PQ',obj.BusType)
                value=-1*obj.getAttachedBusbarValue('RConn2','ReactivePower');
            else
                value=0;
            end
        end

        function value=get.ActualDemandRealPower(obj)
            if strcmp('PQ',obj.BusType)
                value=-1*obj.getAttachedBusbarValue('RConn2','RealPower');
            else
                value=0;
            end
        end

        function value=get.ActualGenerationReactivePower(obj)
            if~strcmp('PQ',obj.BusType)
                value=obj.getAttachedBusbarValue('RConn2','ReactivePower');
            else
                value=0;
            end
        end

        function value=get.ActualGenerationRealPower(obj)
            if~strcmp('PQ',obj.BusType)
                value=obj.getAttachedBusbarValue('RConn2','RealPower');
            else
                value=0;
            end
        end

        function value=get.ActualVoltageMagnitude(obj)
            value=obj.getAttachedBusbarValue('RConn2','VoltageMagnitude');
        end

        function value=get.BusType(obj)
            isInitializationOptionLoadFlow=strcmp('ee.enum.asm.initialization.steadystate',get_param(obj.Name,'initialization_option'));
            isMechanicalPowerConsumedSpecifyOn=strcmp('on',get_param(obj.Name,'mechanical_power_consumed_specify'));
            isMechanicalPowerConsumedPriorityHigh=strcmp('High',get_param(obj.Name,'mechanical_power_consumed_priority'));
            isRealPowerGeneratedSpecifyOn=strcmp('on',get_param(obj.Name,'real_power_generated_specify'));
            isRealPowerGeneratedPriorityHigh=strcmp('High',get_param(obj.Name,'real_power_generated_priority'));

            if isInitializationOptionLoadFlow...
                &&isMechanicalPowerConsumedSpecifyOn...
                &&isMechanicalPowerConsumedPriorityHigh...
                &&~isRealPowerGeneratedSpecifyOn
                value='PQ';
            elseif isInitializationOptionLoadFlow...
                &&~isMechanicalPowerConsumedSpecifyOn...
                &&isRealPowerGeneratedSpecifyOn...
                &&isRealPowerGeneratedPriorityHigh
                value='PV';
            else
                value='';
            end
        end

        function value=get.IsDemandReactivePowerInput(~)
            value=false;
        end

        function value=get.IsDemandRealPowerInput(obj)
            if strcmp('PQ',obj.BusType)
                value=true;
            else
                value=false;
            end
        end

        function value=get.IsGenerationRealPowerInput(obj)
            if strcmp('PV',obj.BusType)
                value=true;
            else
                value=false;
            end
        end

        function value=get.IsVoltageMagnitudeInput(~)
            value=false;
        end

        function value=get.RatedVoltage(obj)
            value=obj.getValue('VRated','kV');
        end

        function value=get.SpecifiedDemandReactivePowerCapacitive(~)
            value=nan;
        end

        function value=get.SpecifiedDemandReactivePowerInductive(~)
            value=nan;
        end

        function value=get.SpecifiedDemandRealPower(obj)
            if strcmp('PQ',obj.BusType)
                value=-1*obj.getValue('mechanical_power_consumed','MW');
            else
                value=0;
            end
        end

        function value=get.SpecifiedGenerationRealPower(obj)
            if strcmp('PV',obj.BusType)
                value=obj.getValue('real_power_generated','MW');
            else
                value=0;
            end
        end

        function value=get.SpecifiedVoltageMagnitude(~)
            value=nan;
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



            value(:,7)=[obj.IsGenerationRealPowerInput]';

            value(:,10)=[obj.IsDemandRealPowerInput]';

            value(:,12)=[obj.IsDemandReactivePowerInput]';

            value(:,13)=[obj.IsDemandReactivePowerInput]';
        end

        function set.BusType(obj,value)
            switch value
            case 'PV'
                set_param(obj.Name,...
                'initialization_option','ee.enum.asm.initialization.steadystate',...
                'mechanical_power_consumed_specify','off',...
                'mechanical_power_consumed_priority','None',...
                'real_power_generated_specify','on',...
                'real_power_generated_priority','High');
            case 'PQ'
                set_param(obj.Name,...
                'initialization_option','ee.enum.asm.initialization.steadystate',...
                'mechanical_power_consumed_specify','on',...
                'mechanical_power_consumed_priority','High',...
                'real_power_generated_specify','off',...
                'real_power_generated_priority','None');
            case 'None'
                set_param(obj.Name,'initialization_option','ee.enum.asm.initialization.fluxvariables');
            otherwise

            end
        end

        function set.RatedVoltage(obj,value)
            obj.setValue('VRated',value,'kV');
        end

        function set.SpecifiedDemandRealPower(obj,value)
            obj.setValue('mechanical_power_consumed',-1*value,'MW');
        end

        function set.SpecifiedGenerationRealPower(obj,value)
            obj.setValue('real_power_generated',value,'MW');
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

