classdef LinearTransformer_class<ConvClass&handle



    properties

        OldParam=struct(...
        'NominalPower',[],...
        'winding1',[],...
        'winding2',[],...
        'winding3',[],...
        'RmLm',[]...
        )


        OldDropdown=struct(...
        'UNITS',[],...
        'Measurements',[],...
        'ThreeWindings',[],...
        'DataType',[]...
        )


        NewDirectParam=struct(...
        'Nw',[],...
        'Nw2',[],...
        'Nw3',[]...
        )


        NewDerivedParam=struct(...
        'R_1',[],...
        'L_1',[],...
        'R_2',[],...
        'L_2',[],...
        'R_3',[],...
        'L_3',[],...
        'R_m',[],...
        'L',[]...
        )


        NewDropdown=struct(...
        )


        BlockOption={...
        {'ThreeWindings','on'},'three';...
        {'ThreeWindings','off'},'two';...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib/Elements/Linear Transformer'
        NewPath='elec_conv_LinearTransformer/LinearTransformer'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.Nw=ConvClass.mapDirect(obj.OldParam.winding1,1);
            obj.NewDirectParam.Nw2=ConvClass.mapDirect(obj.OldParam.winding2,1);
            obj.NewDirectParam.Nw3=ConvClass.mapDirect(obj.OldParam.winding3,1);
        end


        function obj=LinearTransformer_class(UNITS,winding1,winding2,winding3,RmLm,NominalPower)
            if nargin>0
                obj.OldDropdown.UNITS=UNITS;
                obj.OldParam.winding1=winding1;
                obj.OldParam.winding2=winding2;
                obj.OldParam.winding3=winding3;
                obj.OldParam.RmLm=RmLm;
                obj.OldParam.NominalPower=NominalPower;
            end
        end

        function obj=objParamMappingDerived(obj)


            b.S=obj.OldParam.NominalPower(1);
            b.F=obj.OldParam.NominalPower(2);
            b.V(1)=obj.OldParam.winding1(1);
            b.V(2)=obj.OldParam.winding2(1);
            b.V(3)=obj.OldParam.winding3(1);
            b.I=b.S./b.V;
            b.R=b.V./b.I;
            b.L=b.R./(2*pi*b.F);

            switch obj.OldDropdown.UNITS
            case 'pu'

                if obj.OldParam.winding1(2)==0
                    obj.NewDerivedParam.R_1=1e-6;
                else
                    obj.NewDerivedParam.R_1=obj.OldParam.winding1(2)*b.R(1);
                end

                if obj.OldParam.winding2(2)==0
                    obj.NewDerivedParam.R_2=1e-6;
                else
                    obj.NewDerivedParam.R_2=obj.OldParam.winding2(2)*b.R(2);
                end

                if obj.OldParam.winding3(2)==0
                    obj.NewDerivedParam.R_3=1e-6;
                else
                    obj.NewDerivedParam.R_3=obj.OldParam.winding3(2)*b.R(3);
                end

                if obj.OldParam.winding1(3)==0
                    obj.NewDerivedParam.L_1=1e-6;
                else
                    obj.NewDerivedParam.L_1=obj.OldParam.winding1(3)*b.L(1);
                end

                if obj.OldParam.winding2(3)==0
                    obj.NewDerivedParam.L_2=1e-6;
                else
                    obj.NewDerivedParam.L_2=obj.OldParam.winding2(3)*b.L(2);
                end

                if obj.OldParam.winding3(3)==0
                    obj.NewDerivedParam.L_3=1e-6;
                else
                    obj.NewDerivedParam.L_3=obj.OldParam.winding3(3)*b.L(3);
                end

                if obj.OldParam.RmLm(1)==inf
                    obj.NewDerivedParam.R_m=1e6;
                else
                    obj.NewDerivedParam.R_m=obj.OldParam.RmLm(1)*b.R(1);
                end

                if obj.OldParam.RmLm(2)==inf
                    obj.NewDerivedParam.L=1e6;
                else
                    obj.NewDerivedParam.L=obj.OldParam.RmLm(2)*b.L(1);
                end

            case 'SI'

                if obj.OldParam.winding1(2)==0
                    obj.NewDerivedParam.R_1=1e-6;
                else
                    obj.NewDerivedParam.R_1=obj.OldParam.winding1(2);
                end

                if obj.OldParam.winding2(2)==0
                    obj.NewDerivedParam.R_2=1e-6;
                else
                    obj.NewDerivedParam.R_2=obj.OldParam.winding2(2);
                end

                if obj.OldParam.winding3(2)==0
                    obj.NewDerivedParam.R_3=1e-6;
                else
                    obj.NewDerivedParam.R_3=obj.OldParam.winding3(2);
                end

                if obj.OldParam.winding1(3)==0
                    obj.NewDerivedParam.L_1=1e-6;
                else
                    obj.NewDerivedParam.L_1=obj.OldParam.winding1(3);
                end

                if obj.OldParam.winding2(3)==0
                    obj.NewDerivedParam.L_2=1e-6;
                else
                    obj.NewDerivedParam.L_2=obj.OldParam.winding2(3);
                end

                if obj.OldParam.winding3(3)==0
                    obj.NewDerivedParam.L_3=1e-6;
                else
                    obj.NewDerivedParam.L_3=obj.OldParam.winding3(3);
                end

                if obj.OldParam.RmLm(1)==inf
                    obj.NewDerivedParam.R_m=1e6;
                else
                    obj.NewDerivedParam.R_m=obj.OldParam.RmLm(1);
                end

                if obj.OldParam.RmLm(2)==inf
                    obj.NewDerivedParam.L=1e6;
                else
                    obj.NewDerivedParam.L=obj.OldParam.RmLm(2);
                end

            end

        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();


            switch obj.OldDropdown.Measurements
            case 'None'

            case 'Winding voltages'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Winding voltages');
            case 'Winding currents'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Winding currents');
            case 'Magnetization current'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Magnetization current');
            case 'All voltages and currents'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','All voltages and currents');
            end

            logObj.addMessage(obj,'CustomMessage','The magnetic flux might start from an undesired value.');
            logObj.addMessage(obj,'CustomMessage','Please make necessary changes in the block ''Initial Conditions'' tab or select ''Start simulation from steady state'' in the corresponding ''Solver Configuration'' block.');


        end
    end

end
