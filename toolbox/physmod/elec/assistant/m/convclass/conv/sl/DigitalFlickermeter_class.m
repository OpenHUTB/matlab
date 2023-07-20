classdef DigitalFlickermeter_class<ConvClass&handle



    properties

        OldParam=struct(...
        'V_R',[],...
        'Lim_1',[],...
        'Lim_5',[],...
        'Ts',[],...
        'Gain',[],...
        'dVx',[]...
        )


        OldDropdown=struct(...
        'N_freq',[],...
        'type_volt',[],...
        'type_fluc',[],...
        'fmx',[],...
        'Parameter12',[],...
        'test_mode',[]...
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
        OldPath='powerlib_meascontrol/Measurements/Digital Flickermeter'
        NewPath='elec_conv_sl_DigitalFlickermeter/DigitalFlickermeter'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=DigitalFlickermeter_class()
            if nargin>0
            end
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();
            logObj.addMessage(obj,'BlockNotSupported');
        end
    end

end
