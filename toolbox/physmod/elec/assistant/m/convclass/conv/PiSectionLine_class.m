classdef PiSectionLine_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Phases',[],...
        'Frequency',[],...
        'Resistance',[],...
        'Inductance',[],...
        'Capacitance',[],...
        'Length',[],...
        'PiSections',[]...
        )


        OldDropdown=struct(...
        'Measurements',[]...
        )


        NewDirectParam=struct(...
        'L',[],...
        'C',[],...
        'R',[],...
        'LEN',[],...
        'N',[]...
        )


        NewDerivedParam=struct(...
        )


        NewDropdown=struct(...
        )


        BlockOption={...
        {'Phases','1'},'SinglePhase';...
        {},'Others';...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib/Elements/Pi Section Line'
        NewPath='elec_conv_PiSectionLine/PiSectionLine'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.N=obj.OldParam.PiSections;
            obj.NewDirectParam.LEN=obj.OldParam.Length;
            obj.NewDirectParam.R=obj.OldParam.Resistance;
            obj.NewDirectParam.L=obj.OldParam.Inductance;
            obj.NewDirectParam.C=obj.OldParam.Capacitance;
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();

            if~isnumeric(obj.OldParam.Phases)
                logObj.addMessage(obj,'ParameterNumerical','Number of phases [N]');
            end

            if ischar(obj.OldParam.Phases)
                PhasesValue=evalin('base',obj.OldParam.Phases);
            else
                PhasesValue=obj.OldParam.Phases;
            end

            if PhasesValue~=1
                logObj.addMessage(obj,'CustomMessageNoImport','Only Number of phases N = 1 is supported');
            end


            switch obj.OldDropdown.Measurements
            case 'None'

            case 'Input and output voltages'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Input and output voltages');
            case 'Input and output currents'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Input and output currents');
            case 'All pi-section voltages and currents'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','All pi-section voltages and currents');
            case 'All voltages and currents'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','All voltages and currents');
            end

        end
    end

end
