classdef SVPWMGenerator_3_Level__class<ConvClass&handle



    properties

        OldParam=struct(...
        'Kp',[],...
        'fn',[],...
        'Fsw',[],...
        'ParVref',[],...
        'Ts',[]...
        )


        OldDropdown=struct(...
        'InputType',[]...
        )


        NewDirectParam=struct(...
        'Gain',[],...
        'fn',[],...
        'fsw',[],...
        'Amplitude',[]...
        )


        NewDerivedParam=struct(...
        'Ts',[],...
        'Frequency',[],...
        'Phase',[]...
        )


        NewDropdown=struct(...
        )


        BlockOption={...
        {'InputType','Three-phase signals'},'ThreePhase';...
        {'InputType','Magnitude-Angle (rad)'},'MagAng';...
        {'InputType','alpha-beta components'},'AlphaBeta';...
        {'InputType','Internally generated'},'Internal';...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib_meascontrol/Pulse & Signal Generators/SVPWM Generator (3-Level)'
        NewPath='elec_conv_sl_SVPWMGenerator_3_Level_/SVPWMGenerator_3_Level_'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.fsw=obj.OldParam.Fsw;
            obj.NewDirectParam.Gain=obj.OldParam.Kp;
            obj.NewDirectParam.fn=obj.OldParam.fn;
            obj.NewDirectParam.Amplitude=ConvClass.mapDirect(obj.OldParam.ParVref,1);
        end

        function obj=SVPWMGenerator_3_Level__class(ParVref,Ts,Fsw)
            if nargin>0
                obj.OldParam.ParVref=ParVref;
                obj.OldParam.Ts=Ts;
                obj.OldParam.Fsw=Fsw;
            end
        end

        function obj=objParamMappingDerived(obj)

            obj.NewDerivedParam.Frequency=obj.OldParam.ParVref(3)*2*pi;
            obj.NewDerivedParam.Phase=obj.OldParam.ParVref(2)/180*pi+[0,-2*pi/3,2*pi/3];

            if obj.OldParam.Ts==0
                obj.NewDerivedParam.Ts=1/200/obj.OldParam.Fsw;
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

        end
    end

end
