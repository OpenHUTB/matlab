classdef PLL_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Fmin',[],...
        'Par_Init',[],...
        'ParK',[],...
        'TcD',[],...
        'MaxRateChangeFreq',[],...
        'FilterCutOffFreq',[],...
        'Ts',[]...
        )


        OldDropdown=struct(...
        'AGC',[]...
        )


        NewDirectParam=struct(...
        'Kp_LF',[],...
        'Ki_LF',[],...
        'F0',[],...
        'Ts',[]...
        )




        NewDerivedParam=struct(...
        'Theta0',[]...
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
        OldPath='powerlib_meascontrol/PLL/PLL'
        NewPath='elec_conv_sl_PLL/PLL'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.Kp_LF=ConvClass.mapDirect(obj.OldParam.ParK,1);
            obj.NewDirectParam.Ki_LF=ConvClass.mapDirect(obj.OldParam.ParK,2);
            obj.NewDirectParam.F0=ConvClass.mapDirect(obj.OldParam.Par_Init,2);
            obj.NewDirectParam.Ts=obj.OldParam.Ts;
        end

        function obj=PLL_class(Par_Init)
            if nargin>0
                obj.OldParam.Par_Init=Par_Init;
            end
        end

        function obj=objParamMappingDerived(obj)

            obj.NewDerivedParam.Theta0=obj.OldParam.Par_Init(1)/180*pi;

        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();


            if strcmp(obj.OldDropdown.AGC,'on')
                logObj.addMessage(obj,'CheckboxNotSupported','Enable automatic gain control');
            end

            logObj.addMessage(obj,'ParameterNotSupported','Minimum frequency (Hz)');
            logObj.addMessage(obj,'ParameterNotSupported','Time constant for derivative action (s)');
            logObj.addMessage(obj,'ParameterNotSupported','Maximum rate of change of frequency (Hz/s)');
            logObj.addMessage(obj,'ParameterNotSupported','Filter cut-off frequency for frequency measurement (Hz)');
        end
    end

end
