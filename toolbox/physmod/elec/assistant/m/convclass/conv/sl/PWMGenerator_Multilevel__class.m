classdef PWMGenerator_Multilevel__class<ConvClass&handle



    properties

        OldParam=struct(...
        'NumberOfBridges',[],...
        'Fc',[],...
        'Ts',[]...
        )


        OldDropdown=struct(...
        'BridgeType',[],...
        'ShowCarriersOutport',[]...
        )


        NewDirectParam=struct(...
        'Nsm',[],...
        'Ts',[]...
        )


        NewDerivedParam=struct(...
        'Tper',[]...
        )


        NewDropdown=struct(...
        'topology',[]...
        )


        BlockOption={...
        }
        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib_meascontrol/Pulse & Signal Generators/PWM Generator (Multilevel)'
        NewPath='elec_conv_sl_PWMGenerator_Multilevel_/PWMGenerator_Multilevel_'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.Nsm=obj.OldParam.NumberOfBridges;
            obj.NewDirectParam.Ts=obj.OldParam.Ts;
        end

        function obj=PWMGenerator_Multilevel__class(Fc)
            if nargin>0
                obj.OldParam.Fc=Fc;
            end
        end

        function obj=objParamMappingDerived(obj)

            obj.NewDerivedParam.Tper=1/(2*obj.OldParam.Fc);

        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();

            if strcmp(obj.OldDropdown.BridgeType,'Half-bridge')
                obj.NewDropdown.topology='Half-bridge';
            else
                obj.NewDropdown.topology='Full-bridge';
            end

            if strcmp(obj.OldDropdown.ShowCarriersOutport,'on')
                logObj.addMessage(obj,'ParameterNotSupported','Show carriers outport');
            end

        end
    end

end
