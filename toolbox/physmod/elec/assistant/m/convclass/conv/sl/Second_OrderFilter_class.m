classdef Second_OrderFilter_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Fo',[],...
        'Zeta',[],...
        'Ts',[],...
        'Vac_Init',[],...
        'Vdc_Init',[],...
        'FreqRange',[]...
        )


        OldDropdown=struct(...
        'FilterType',[],...
        'Initialize',[],...
        'PlotResponse',[]...
        )


        NewDirectParam=struct(...
        'Ts',[],...
        'A0',[],...
        'f0',[],...
        'b0',[],...
        'Ph0',[]...
        )


        NewDerivedParam=struct(...
        'fn',[],...
        'Zeta',[]...
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
        OldPath='powerlib_meascontrol/Filters/Second-Order Filter'
        NewPath='elec_conv_sl_Second_OrderFilter/Second_OrderFilter'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.Ts=obj.OldParam.Ts;
            obj.NewDirectParam.b0=0;
            obj.NewDirectParam.A0=0;
            obj.NewDirectParam.f0=0;
            obj.NewDirectParam.Ph0=0;
        end

        function obj=Second_OrderFilter_class(Fo,Zeta)
            if nargin>0
                obj.OldParam.Fo=Fo;
                obj.OldParam.Zeta=Zeta;
            end
        end

        function obj=objParamMappingDerived(obj)

            obj.NewDerivedParam.fn=obj.OldParam.Fo(1);
            obj.NewDerivedParam.Zeta=obj.OldParam.Zeta(1);

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
