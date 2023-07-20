classdef Second_OrderFilter_Varia_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Fo',[],...
        'Zeta',[],...
        'Ts',[],...
        'Vac_Init',[],...
        'Vdc_Init',[]...
        )


        OldDropdown=struct(...
        'FilterType',[],...
        'Initialize',[],...
        'PlotResponse',[]...
        )


        NewDirectParam=struct(...
        'fn',[],...
        'Zeta',[],...
        'Ts',[],...
        'A0',[],...
        'f0',[],...
        'b0',[],...
        'Ph0',[]...
        )


        NewDerivedParam=struct(...
        )


        NewDropdown=struct(...
        'FilterType',[]...
        )


        BlockOption={...
        }
        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib_meascontrol/Filters/Second-Order Filter (Variable-Tuned)'
        NewPath='elec_conv_sl_Second_OrderFilter_Varia/Second_OrderFilter_Varia'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.fn=ConvClass.mapDirect(obj.OldParam.Fo,1);
            obj.NewDirectParam.Zeta=ConvClass.mapDirect(obj.OldParam.Zeta,1);
            obj.NewDirectParam.Ts=ConvClass.mapDirect(obj.OldParam.Ts,1);
            obj.NewDirectParam.b0=0;
            obj.NewDirectParam.A0=0;
            obj.NewDirectParam.f0=0;
            obj.NewDirectParam.Ph0=0;
        end

        function obj=Second_OrderFilter_Varia_class()
            if nargin>0
            end
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
            switch obj.OldDropdown.FilterType
            case 'Lowpass'
                obj.NewDropdown.FilterType='Low-pass';
            case 'Highpass'
                obj.NewDropdown.FilterType='High-pass';
            case 'Bandpass'
                obj.NewDropdown.FilterType='Band-pass';
            case 'Bandstop (Notch)'
                obj.NewDropdown.FilterType='Band-stop';
            end

            logObj=ElecAssistantLog.getInstance();
            logObj.addMessage(obj,'CustomMessage','All parameters have to be scalar');
        end
    end

end
