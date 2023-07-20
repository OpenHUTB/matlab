classdef SVPWMGenerator_2_Level__class<ConvClass&handle



    properties

        OldParam=struct(...
        'Fc',[],...
        'ParUref',[],...
        'Ts',[]...
        )


        OldDropdown=struct(...
        'InputType',[],...
        'SwitchingPattern',[]...
        )


        NewDirectParam=struct(...
        'fsw',[],...
        'Amplitude',[]...
        )


        NewDerivedParam=struct(...
        'Ts',[],...
        'Frequency',[],...
        'Phase',[]...
        )


        NewDropdown=struct(...
        'PWMMode',[],...
        'CPWMMode',[],...
        'DPWMMode',[],...
        'SamplingMode',[]...
        )


        BlockOption={...
        {'InputType','Magnitude-Angle (rad)'},'MagAng';...
        {'InputType','alpha-beta components'},'AlphaBeta';...
        {'InputType','Internally generated'},'Internal';...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib_meascontrol/Pulse & Signal Generators/SVPWM Generator (2-Level)'
        NewPath='elec_conv_sl_SVPWMGenerator_2_Level_/SVPWMGenerator_2_Level_'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.fsw=obj.OldParam.Fc;
            obj.NewDirectParam.Amplitude=ConvClass.mapDirect(obj.OldParam.ParUref,1);
        end

        function obj=SVPWMGenerator_2_Level__class(ParUref,Ts,Fc)
            if nargin>0
                obj.OldParam.ParUref=ParUref;
                obj.OldParam.Ts=Ts;
                obj.OldParam.Fc=Fc;
            end
        end

        function obj=objParamMappingDerived(obj)

            obj.NewDerivedParam.Frequency=obj.OldParam.ParUref(3)*2*pi;
            obj.NewDerivedParam.Phase=obj.OldParam.ParUref(2)/180*pi+pi/2+[0,-2*pi/3,2*pi/3];

            if obj.OldParam.Ts==0
                obj.NewDerivedParam.Ts=1/200/obj.OldParam.Fc;
            else
                obj.NewDerivedParam.Ts=obj.OldParam.Ts;
            end

        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();

            if ischar(obj.OldParam.Ts)
                obj.OldParam.Ts=evalin('base',obj.OldParam.Ts);
            end

            if obj.OldParam.Ts==0
                logObj.addMessage(obj,'ParameterNotSupported','Sample time = 0');
                logObj.addMessage(obj,'CustomMessageNoImport','Sample time is set to 200 times smaller than the Carrier period');
            end


            if strcmp(obj.OldDropdown.SwitchingPattern,'Pattern #2')
                logObj.addMessage(obj,'OptionNotSupported','Switching pattern','Pattern #2');
            end

        end
    end

end
