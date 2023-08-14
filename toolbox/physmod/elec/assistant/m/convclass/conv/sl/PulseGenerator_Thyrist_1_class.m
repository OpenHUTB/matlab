classdef PulseGenerator_Thyrist_1_class<ConvClass&handle



    properties

        OldParam=struct(...
        'pwidth',[],...
        'Ts',[]...
        )


        OldDropdown=struct(...
        'GenType',[],...
        'Delta',[],...
        'Double_Pulse',[]...
        )


        NewDirectParam=struct(...
        )


        NewDerivedParam=struct(...
        'Pw',[],...
        'Ts',[]...
        )


        NewDropdown=struct(...
        'Dcon',[]...
        )


        BlockOption={...
        {'GenType','6-pulse'},'6';...
        {'GenType','12-pulse'},'12'
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib_meascontrol/Pulse & Signal Generators/Pulse Generator (Thyristor, 6-Pulse)'
        NewPath='elec_conv_sl_PulseGenerator_Thyrist_1/PulseGenerator_Thyrist_1'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=PulseGenerator_Thyrist_1_class(pwidth,Ts,Double_Pulse)
            if nargin>0
                obj.OldParam.pwidth=pwidth;
                obj.OldParam.Ts=Ts;
                obj.OldParam.Double_Pulse=Double_Pulse;
            end
        end

        function obj=objParamMappingDerived(obj)

            if strcmp(obj.OldDropdown.Double_Pulse,'off')
                obj.NewDerivedParam.Pw=obj.OldParam.pwidth/180*pi;
            else
                obj.NewDerivedParam.Pw=150/180*pi;
            end

            if obj.OldParam.Ts==0
                obj.NewDerivedParam.Ts=1e-5;
            else
                obj.NewDerivedParam.Ts=obj.OldParam.Ts;
            end

        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();


            if strcmp(obj.OldDropdown.Double_Pulse,'on')
                logObj.addMessage(obj,'CheckboxNotSupported','Double pulsing');
                logObj.addMessage(obj,'CustomMessageNoImport','The ''Pulse width'' is set as 5*pi/6 rad');
            end

            if ischar(obj.OldParam.Ts)
                obj.OldParam.Ts=evalin('base',obj.OldParam.Ts);
            end
            if obj.OldParam.Ts==0
                logObj.addMessage(obj,'ParameterNotSupported','Sample time = 0');
                logObj.addMessage(obj,'CustomMessageNoImport','Sample time is set to be 1e-5 second');
            end


            switch obj.OldDropdown.Delta
            case 'D1 (lagging)'
                obj.NewDropdown.Dcon='Lagging (Delta1)';
            case 'D11 (leading)'
                obj.NewDropdown.Dcon='Leading (Delta11)';
            end
        end
    end

end
