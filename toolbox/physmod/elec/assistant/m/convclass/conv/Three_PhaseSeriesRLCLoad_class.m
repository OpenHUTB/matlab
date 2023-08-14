classdef Three_PhaseSeriesRLCLoad_class<ConvClass&handle



    properties

        OldParam=struct(...
        'NominalVoltage',[],...
        'Vabc',[],...
        'Vabcp',[],...
        'NominalFrequency',[],...
        'ActivePower',[],...
        'InductivePower',[],...
        'CapacitivePower',[],...
        'Pabc',[],...
        'QLabc',[],...
        'QCabc',[],...
        'Pabcp',[],...
        'QLabcp',[],...
        'QCabcp',[]...
        )


        OldDropdown=struct(...
        'Configuration',[],...
        'Measurements',[],...
        'LoadType',[],...
        'UnbalancedPower',[]...
        )


        NewDirectParam=struct(...
        'P',[],...
        'Qpos',[],...
        'VRated',[],...
        'FRated',[],...
        'Vmag0',[]...
        )


        NewDerivedParam=struct(...
        'Qneg',[]...
        )













        NewDropdown=struct(...
        'component_structure',[],...
        'component_structure_PQ',[]...
        )


        BlockOption={...
        {'Configuration','Y (grounded)'},'Yg';...
        {'Configuration','Y (floating)'},'Yf';...
        {'Configuration','Y (neutral)'},'Yn';...
        {'Configuration','Delta'},'D';...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib/Elements/Three-Phase Series RLC Load'
        NewPath='elec_conv_Three_PhaseSeriesRLCLoad/Three_PhaseSeriesRLCLoad'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.P=obj.OldParam.ActivePower;
            obj.NewDirectParam.Qpos=obj.OldParam.InductivePower;
            obj.NewDirectParam.VRated=obj.OldParam.NominalVoltage;
            obj.NewDirectParam.Vmag0=obj.OldParam.NominalVoltage;
            obj.NewDirectParam.FRated=obj.OldParam.NominalFrequency;
        end


        function obj=Three_PhaseSeriesRLCLoad_class(CapacitivePower)
            if nargin>0
                obj.OldParam.CapacitivePower=CapacitivePower;
            end
        end

        function obj=objParamMappingDerived(obj)

            obj.NewDerivedParam.Qneg=-obj.OldParam.CapacitivePower;

        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();


            switch obj.OldDropdown.Measurements
            case 'None'

            case 'Branch voltages'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Branch voltages');
            case 'Branch currents'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Branch currents');
            case 'Branch voltages and currents'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Branch voltages and currents');
            end

            if strcmp(obj.OldDropdown.UnbalancedPower,'on')
                logObj.addMessage(obj,'CheckboxNotSupportedNoImport','Specify PQ powers for each phase');
            end

            if ischar(obj.OldParam.ActivePower)
                ActivePowerValue=evalin('base',obj.OldParam.ActivePower);
            else
                ActivePowerValue=obj.OldParam.ActivePower;
            end
            if ischar(obj.OldParam.InductivePower)
                InductivePowerValue=evalin('base',obj.OldParam.InductivePower);
            else
                InductivePowerValue=obj.OldParam.InductivePower;
            end
            if ischar(obj.OldParam.CapacitivePower)
                CapacitivePowerValue=evalin('base',obj.OldParam.CapacitivePower);
            else
                CapacitivePowerValue=obj.OldParam.CapacitivePower;
            end

            if ActivePowerValue~=0&&...
                InductivePowerValue==0&&...
                CapacitivePowerValue==0
                obj.NewDropdown.component_structure_PQ='1';
                obj.NewDropdown.component_structure='1';
            elseif ActivePowerValue==0&&...
                InductivePowerValue~=0&&...
                CapacitivePowerValue==0
                obj.NewDropdown.component_structure_PQ='2';
                obj.NewDropdown.component_structure='2';
            elseif ActivePowerValue==0&&...
                InductivePowerValue==0&&...
                CapacitivePowerValue~=0
                obj.NewDropdown.component_structure_PQ='3';
                obj.NewDropdown.component_structure='3';
            elseif ActivePowerValue~=0&&...
                InductivePowerValue~=0&&...
                CapacitivePowerValue==0
                obj.NewDropdown.component_structure_PQ='4';
                obj.NewDropdown.component_structure='4';
            elseif ActivePowerValue~=0&&...
                InductivePowerValue==0&&...
                CapacitivePowerValue~=0
                obj.NewDropdown.component_structure_PQ='5';
                obj.NewDropdown.component_structure='5';
            elseif ActivePowerValue==0&&...
                InductivePowerValue~=0&&...
                CapacitivePowerValue~=0
                obj.NewDropdown.component_structure_PQ='6';
                obj.NewDropdown.component_structure='6';
            elseif ActivePowerValue~=0&&...
                InductivePowerValue~=0&&...
                CapacitivePowerValue~=0
                obj.NewDropdown.component_structure_PQ='7';
                obj.NewDropdown.component_structure='7';
            else

            end

            if InductivePowerValue~=0||...
                CapacitivePowerValue~=0
                logObj.addMessage(obj,'CustomMessage','The load current might start from an undesired value.');
                logObj.addMessage(obj,'CustomMessage','Please make necessary changes in the block ''Initial Conditions'' tab or select ''Start simulation from steady state'' in the corresponding ''Solver Configuration'' block.');
            end

        end
    end

end
