classdef RMS_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Freq',[],...
        'RMSInit',[],...
        'Ts',[]...
        )


        OldDropdown=struct(...
        'TrueRMS',[]...
        )


        NewDirectParam=struct(...
        'F',[],...
        'K',[],...
        'Ts',[]...
        )


        NewDerivedParam=struct(...
        )


        NewDropdown=struct(...
        'SpecifyHarmonics',[]...
        )


        BlockOption={...
        {'TrueRMS','on'},'TrueRMSon';...
        {'TrueRMS','off'},'TrueRMSoff';...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib_meascontrol/Measurements/RMS'
        NewPath='elec_conv_sl_RMS/RMS'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.F=obj.OldParam.Freq;
            obj.NewDirectParam.Ts=obj.OldParam.Ts;
        end

        function obj=RMS_class()
            if nargin>0
            end
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();





        end
    end

end
