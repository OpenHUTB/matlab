classdef Power_PLL_Driven_Positiv_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Finit',[],...
        'Fmin',[],...
        'Vinit',[],...
        'Iinit',[],...
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
        'i_init_ax',[],...
        'i_init_ay',[],...
        'i_init_bx',[],...
        'i_init_by',[],...
        'i_init_cx',[],...
        'i_init_cy',[],...
        'v_init_ax',[],...
        'v_init_ay',[],...
        'v_init_bx',[],...
        'v_init_by',[],...
        'v_init_cx',[],...
        'v_init_cy',[]...
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
        OldPath='powerlib_meascontrol/Measurements/Power (PLL-Driven, Positive-Sequence)'
        NewPath='elec_conv_sl_Power_PLL_Driven_Positiv/Power_PLL_Driven_Positiv'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.f0=obj.OldParam.Finit;
            obj.NewDirectParam.fmin=obj.OldParam.Fmin;
            obj.NewDirectParam.Ts=obj.OldParam.Ts;
        end

        function obj=Power_PLL_Driven_Positiv_class(Vinit,Iinit)
            if nargin>0
                obj.OldParam.Vinit=Vinit;
                obj.OldParam.Iinit=Iinit;
            end
        end

        function obj=objParamMappingDerived(obj)

            Vmag=obj.OldParam.Vinit(1);
            Vang=obj.OldParam.Vinit(2)/180*pi;
            obj.NewDerivedParam.v_init_ax=Vmag*cos(Vang)/2;
            obj.NewDerivedParam.v_init_ay=Vmag*sin(Vang)/2;
            obj.NewDerivedParam.v_init_bx=Vmag*cos(Vang-2*pi/3)/2;
            obj.NewDerivedParam.v_init_by=Vmag*sin(Vang-2*pi/3)/2;
            obj.NewDerivedParam.v_init_cx=Vmag*cos(Vang-4*pi/3)/2;
            obj.NewDerivedParam.v_init_cy=Vmag*sin(Vang-4*pi/3)/2;

            Imag=obj.OldParam.Iinit(1);
            Iang=obj.OldParam.Iinit(2)/180*pi;
            obj.NewDerivedParam.i_init_ax=Imag*cos(Iang)/2;
            obj.NewDerivedParam.i_init_ay=Imag*sin(Iang)/2;
            obj.NewDerivedParam.i_init_bx=Imag*cos(Iang-2*pi/3)/2;
            obj.NewDerivedParam.i_init_by=Imag*sin(Iang-2*pi/3)/2;
            obj.NewDerivedParam.i_init_cx=Imag*cos(Iang-4*pi/3)/2;
            obj.NewDerivedParam.i_init_cy=Imag*sin(Iang-4*pi/3)/2;

        end

        function obj=objDropdownMapping(obj)
        end
    end

end
