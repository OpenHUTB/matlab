classdef CurrentMeasurement_class<ConvClass&handle


    properties

        OldParam=struct(...
        'PSBequivalent',[]...
        )


        OldDropdown=struct(...
        'OutputType',[],...
        'PhasorSimulation',[]...
        )


        NewDirectParam=struct(...
        )


        NewDerivedParam=struct(...
        )


        NewDropdown=struct(...
        )


        BlockOption={...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end


    properties(Constant)
        OldPath='powerlib/Measurements/Current Measurement'
        NewPath='elec_conv_CurrentMeasurement/CurrentMeasurement'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();


            if strcmp(obj.OldDropdown.PhasorSimulation,'on')
                switch obj.OldDropdown.OutputType
                case 'Complex'
                    logObj.addMessage(obj,'OptionNotSupported','Output signal','Complex');
                case 'Real-Imag'
                    logObj.addMessage(obj,'OptionNotSupported','Output signal','Real-Imag');
                case 'Magnitude-Angle'
                    logObj.addMessage(obj,'OptionNotSupported','Output signal','Magnitude-Angle');
                otherwise
                    logObj.addMessage(obj,'OptionNotSupported','Output signal','Magnitude');
                end
            end
        end
    end

end
