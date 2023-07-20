classdef Fundamental_PLL_Driven__class<ConvClass&handle



    properties

        OldParam=struct(...
        'Finit',[],...
        'Fmin',[],...
        'InInit',[],...
        'Ts',[]...
        )


        OldDropdown=struct(...
        )


        NewDirectParam=struct(...
        'f0',[],...
        'fmin',[],...
        'Ts',[]...
        )


        NewDerivedParam=struct(...
        'init_a',[],...
        'init_b',[]...
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
        OldPath='powerlib_meascontrol/Measurements/Fundamental (PLL-Driven)'
        NewPath='elec_conv_sl_Fundamental_PLL_Driven_/Fundamental_PLL_Driven_'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.f0=obj.OldParam.Finit;
            obj.NewDirectParam.fmin=obj.OldParam.Fmin;
            obj.NewDirectParam.Ts=obj.OldParam.Ts;
        end

        function obj=Fundamental_PLL_Driven__class(InInit)
            if nargin>0
                obj.OldParam.InInit=InInit;
            end
        end

        function obj=objParamMappingDerived(obj)

            mag=obj.OldParam.InInit(1);
            ang=obj.OldParam.InInit(2)/180*pi;
            obj.NewDerivedParam.init_a=mag*cos(ang);
            obj.NewDerivedParam.init_b=mag*sin(ang);

        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();
        end
    end

end
