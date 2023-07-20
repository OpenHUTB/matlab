classdef Fourier_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Freq',[],...
        'n',[],...
        'InInit',[],...
        'Ts',[]...
        )


        OldDropdown=struct(...
        )


        NewDirectParam=struct(...
        'f',[],...
        'n',[],...
        'Ts',[]...
        )


        NewDerivedParam=struct(...
        'M0',[],...
        'Ph0',[]...
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
        OldPath='powerlib_meascontrol/Measurements/Fourier'
        NewPath='elec_conv_sl_Fourier/Fourier'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.f=obj.OldParam.Freq;
            obj.NewDirectParam.n=obj.OldParam.n;
            obj.NewDirectParam.Ts=obj.OldParam.Ts;
        end

        function obj=Fourier_class(InInit)
            if nargin>0
                obj.OldParam.InInit=InInit;
            end
        end

        function obj=objParamMappingDerived(obj)

            obj.NewDerivedParam.M0=obj.OldParam.InInit(:,1);
            obj.NewDerivedParam.Ph0=obj.OldParam.InInit(:,2)/180*pi;

        end

        function obj=objDropdownMapping(obj)
        end
    end

end
