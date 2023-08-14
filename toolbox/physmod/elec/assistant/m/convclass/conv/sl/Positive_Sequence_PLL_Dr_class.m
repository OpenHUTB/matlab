classdef Positive_Sequence_PLL_Dr_class<ConvClass&handle



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
        'init_ax',[],...
        'init_ay',[],...
        'init_bx',[],...
        'init_by',[],...
        'init_cx',[],...
        'init_cy',[]...
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
        OldPath='powerlib_meascontrol/Measurements/Positive-Sequence (PLL-Driven)'
        NewPath='elec_conv_sl_Positive_Sequence_PLL_Dr/Positive_Sequence_PLL_Dr'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.f0=obj.OldParam.Finit;
            obj.NewDirectParam.fmin=obj.OldParam.Fmin;
            obj.NewDirectParam.Ts=obj.OldParam.Ts;
        end

        function obj=Positive_Sequence_PLL_Dr_class(InInit)
            if nargin>0
                obj.OldParam.InInit=InInit;
            end
        end

        function obj=objParamMappingDerived(obj)

            mag=obj.OldParam.InInit(1);
            ang=obj.OldParam.InInit(2)/180*pi;
            obj.NewDerivedParam.init_ax=mag*cos(ang)/2;
            obj.NewDerivedParam.init_ay=mag*sin(ang)/2;
            obj.NewDerivedParam.init_bx=mag*cos(ang-2*pi/3)/2;
            obj.NewDerivedParam.init_by=mag*sin(ang-2*pi/3)/2;
            obj.NewDerivedParam.init_cx=mag*cos(ang-4*pi/3)/2;
            obj.NewDerivedParam.init_cy=mag*sin(ang-4*pi/3)/2;

        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();
        end
    end

end
