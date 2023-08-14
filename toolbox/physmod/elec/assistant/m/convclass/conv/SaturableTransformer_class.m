classdef SaturableTransformer_class<ConvClass&handle



    properties

        OldParam=struct(...
        'DataFile',[],...
        'NominalPower',[],...
        'Winding1',[],...
        'Winding2',[],...
        'Winding3',[],...
        'Saturation',[],...
        'CoreLoss',[],...
        'InitialFlux',[]...
        )


        OldDropdown=struct(...
        'Measurements',[],...
        'UNITS',[],...
        'ThreeWindings',[],...
        'Hysteresis',[],...
        'BreakLoop',[]...
        )


        NewDirectParam=struct(...
        )


        NewDerivedParam=struct(...
        'Nw',[],...
        'Nw2',[],...
        'Nw3',[],...
        'R_1',[],...
        'L_1',[],...
        'R_2',[],...
        'L_2',[],...
        'R_3',[],...
        'L_3',[],...
        'R_m',[],...
        'phi0',[],...
        'current_data',[],...
        'magnetic_flux_data',[]...
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
        OldPath='powerlib/Elements/Saturable Transformer'
        NewPath='elec_conv_SaturableTransformer/SaturableTransformer'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end


        function obj=SaturableTransformer_class(UNITS,Winding1,Winding2,Winding3,NominalPower,CoreLoss,Saturation,InitialFlux)
            if nargin>0
                obj.OldDropdown.UNITS=UNITS;
                obj.OldParam.Winding1=Winding1;
                obj.OldParam.Winding2=Winding2;
                obj.OldParam.Winding3=Winding3;
                obj.OldParam.NominalPower=NominalPower;
                obj.OldParam.CoreLoss=CoreLoss;
                obj.OldParam.Saturation=Saturation;
                obj.OldParam.InitialFlux=InitialFlux;
            end
        end

        function obj=objParamMappingDerived(obj)

            obj.NewDerivedParam.Nw=obj.OldParam.Winding1(1);
            obj.NewDerivedParam.Nw2=obj.OldParam.Winding2(1);
            obj.NewDerivedParam.Nw3=obj.OldParam.Winding3(1);
            SRated=obj.OldParam.NominalPower(1);
            FRated=obj.OldParam.NominalPower(2);
            VRated1=obj.OldParam.Winding1(1);
            VRated2=obj.OldParam.Winding2(1);
            VRated3=obj.OldParam.Winding3(1);
            b1.R=VRated1^2/SRated;
            b1.L=VRated1^2/SRated/(2*pi*FRated);
            b1.I=SRated/VRated1;
            b1.Phi=b1.L*b1.I;
            b2.R=VRated2^2/SRated;
            b2.L=VRated2^2/SRated/(2*pi*FRated);
            b3.R=VRated3^2/SRated;
            b3.L=VRated3^2/SRated/(2*pi*FRated);

            switch obj.OldDropdown.UNITS
            case 'SI'

                if obj.OldParam.Winding1(2)==0
                    obj.NewDerivedParam.R_1=1e-6;
                else
                    obj.NewDerivedParam.R_1=obj.OldParam.Winding1(2);
                end

                if obj.OldParam.Winding2(2)==0
                    obj.NewDerivedParam.R_2=1e-6;
                else
                    obj.NewDerivedParam.R_2=obj.OldParam.Winding2(2);
                end

                if obj.OldParam.Winding3(2)==0
                    obj.NewDerivedParam.R_3=1e-6;
                else
                    obj.NewDerivedParam.R_3=obj.OldParam.Winding3(2);
                end

                if obj.OldParam.Winding1(3)==0
                    obj.NewDerivedParam.L_1=1e-6;
                else
                    obj.NewDerivedParam.L_1=obj.OldParam.Winding1(3);
                end

                if obj.OldParam.Winding2(3)==0
                    obj.NewDerivedParam.L_2=1e-6;
                else
                    obj.NewDerivedParam.L_2=obj.OldParam.Winding2(3);
                end

                if obj.OldParam.Winding3(3)==0
                    obj.NewDerivedParam.L_3=1e-6;
                else
                    obj.NewDerivedParam.L_3=obj.OldParam.Winding3(3);
                end

                if obj.OldParam.CoreLoss(1)==inf
                    obj.NewDerivedParam.R_m=1e6;
                else
                    obj.NewDerivedParam.R_m=obj.OldParam.CoreLoss(1);
                end


                if size(obj.OldParam.CoreLoss,2)==2
                    obj.NewDerivedParam.phi0=obj.OldParam.CoreLoss(2)/obj.NewDerivedParam.Nw;
                else
                    obj.NewDerivedParam.phi0=obj.OldParam.InitialFlux/obj.NewDerivedParam.Nw;
                end
                obj.NewDerivedParam.current_data=obj.OldParam.Saturation(:,1)';
                obj.NewDerivedParam.magnetic_flux_data=obj.OldParam.Saturation(:,2)'/obj.NewDerivedParam.Nw;

            case 'pu'

                if obj.OldParam.Winding1(2)==0
                    obj.NewDerivedParam.R_1=1e-6;
                else
                    obj.NewDerivedParam.R_1=obj.OldParam.Winding1(2)*b1.R;
                end

                if obj.OldParam.Winding2(2)==0
                    obj.NewDerivedParam.R_2=1e-6;
                else
                    obj.NewDerivedParam.R_2=obj.OldParam.Winding2(2)*b2.R;
                end

                if obj.OldParam.Winding3(2)==0
                    obj.NewDerivedParam.R_3=1e-6;
                else
                    obj.NewDerivedParam.R_3=obj.OldParam.Winding3(2)*b3.R;
                end

                if obj.OldParam.Winding1(3)==0
                    obj.NewDerivedParam.L_1=1e-6;
                else
                    obj.NewDerivedParam.L_1=obj.OldParam.Winding1(3)*b1.L;
                end

                if obj.OldParam.Winding2(3)==0
                    obj.NewDerivedParam.L_2=1e-6;
                else
                    obj.NewDerivedParam.L_2=obj.OldParam.Winding2(3)*b2.L;
                end

                if obj.OldParam.Winding3(3)==0
                    obj.NewDerivedParam.L_3=1e-6;
                else
                    obj.NewDerivedParam.L_3=obj.OldParam.Winding3(3)*b3.L;
                end

                if obj.OldParam.CoreLoss(1)==inf
                    obj.NewDerivedParam.R_m=1e6;
                else
                    obj.NewDerivedParam.R_m=obj.OldParam.CoreLoss(1)*b1.R;
                end

                if size(obj.OldParam.CoreLoss,2)==2
                    obj.NewDerivedParam.phi0=obj.OldParam.CoreLoss(2)*(b1.Phi*sqrt(2))/obj.NewDerivedParam.Nw;
                else
                    obj.NewDerivedParam.phi0=obj.OldParam.InitialFlux/obj.NewDerivedParam.Nw;
                end
                obj.NewDerivedParam.current_data=...
                obj.strictMonoArray(obj.OldParam.Saturation(:,1)'*(b1.I*sqrt(2)));
                obj.NewDerivedParam.magnetic_flux_data=...
                obj.strictMonoArray(obj.OldParam.Saturation(:,2)'*(b1.Phi*sqrt(2))/obj.NewDerivedParam.Nw);
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
            case 'Flux and excitation current ( Imag + IRm )'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Flux and excitation current ( Imag + IRm )');
            case 'Flux and magnetization current ( Imag )'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Flux and magnetization current ( Imag )');
            case 'All measurements (V I Flux)'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','All measurements (V I Flux)');
            end

            if strcmp(obj.OldDropdown.Hysteresis,'on')
                logObj.addMessage(obj,'CheckboxNotSupported','Simulate hysteresis');
            end

        end
    end

end
