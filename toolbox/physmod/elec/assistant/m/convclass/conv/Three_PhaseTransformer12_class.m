classdef Three_PhaseTransformer12_class<ConvClass&handle



    properties

        OldParam=struct(...
        'RatedPower',[],...
        'Winding1',[],...
        'Winding2',[],...
        'RmXm',[]...
        )


        OldDropdown=struct(...
        )


        NewDirectParam=struct(...
        'Nw',[],...
        'Nw2',[]...
        )


        NewDerivedParam=struct(...
        'R_1',[],...
        'L_1',[],...
        'R_2',[],...
        'L_2',[],...
        'R_m',[],...
        'L',[]...
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
        OldPath='powerlib/Elements/Three-Phase Transformer 12 Terminals'
        NewPath='elec_conv_Three_PhaseTransformer12/Three_PhaseTransformer12'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.Nw=ConvClass.mapDirect(obj.OldParam.Winding1,1);
            obj.NewDirectParam.Nw2=ConvClass.mapDirect(obj.OldParam.Winding2,1);
        end


        function obj=Three_PhaseTransformer12_class(RatedPower,Winding1,Winding2,RmXm)
            if nargin>0
                obj.OldParam.RatedPower=RatedPower;
                obj.OldParam.Winding1=Winding1;
                obj.OldParam.Winding2=Winding2;
                obj.OldParam.RmXm=RmXm;
            end
        end

        function obj=objParamMappingDerived(obj)



            b.S=obj.OldParam.RatedPower(1)/3;
            b.wElectrical=obj.OldParam.RatedPower(2)*2*pi;
            b.V(1)=obj.OldParam.Winding1(1);
            b.V(2)=obj.OldParam.Winding2(1);
            b.I=b.S./b.V;
            b.Z=b.V./b.I;
            b.L=b.Z./b.wElectrical;


            obj.NewDerivedParam.R_1=max(obj.OldParam.Winding1(2)*b.Z(1),1e-6);
            obj.NewDerivedParam.L_1=max(obj.OldParam.Winding1(3)*b.L(1),1e-6);
            obj.NewDerivedParam.R_2=max(obj.OldParam.Winding2(2)*b.Z(2),1e-6);
            obj.NewDerivedParam.L_2=max(obj.OldParam.Winding2(3)*b.L(2),1e-6);
            obj.NewDerivedParam.R_m=min(max(obj.OldParam.RmXm(1)*b.Z(1),1e-6),1e6);
            obj.NewDerivedParam.L=min(max(obj.OldParam.RmXm(2)*b.L(1),1e-6),1e6);


        end

        function obj=objDropdownMapping(obj)
        end
    end

end
