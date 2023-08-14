classdef Three_PhaseTransformer_2_class<ConvClass&handle



    properties

        OldParam=struct(...
        'DataFile',[],...
        'NominalPower',[],...
        'Winding1',[],...
        'Winding2',[],...
        'Rm',[],...
        'Lm',[],...
        'L0',[],...
        'Saturation',[],...
        'InitialFluxes',[],...
        'TransfoNumber',[]...
        )


        OldDropdown=struct(...
        'Winding1Connection',[],...
        'Winding2Connection',[],...
        'CoreType',[],...
        'Measurements',[],...
        'UNITS',[],...
        'SetSaturation',[],...
        'Hysteresis',[],...
        'SetInitialFlux',[],...
        'BreakLoop',[],...
        'DataType',[]...
        )


        NewDirectParam=struct(...
        'SRated',[],...
        'FRated',[],...
        'VRated1',[],...
        'VRated2',[],...
        'phi_specify',[],...
        'phi_priority',[]...
        )


        NewDerivedParam=struct(...
        'pu_Rw1',[],...
        'pu_Xl1',[],...
        'pu_Rw2',[],...
        'pu_Xl2',[],...
        'pu_Rm',[],...
        'pu_Xm',[],...
        'pu_X0',[],...
        'current_data',[],...
        'magnetic_flux_data',[],...
        'phi',[]...
        )


        NewDropdown=struct(...
        'Winding1Connection',[],...
        'Winding2Connection',[],...
        'saturation_option',[],...
        'CoreType',[]...
        )


        BlockOption={...
        {'Winding1Connection','Yg';'Winding2Connection','Yg'},'W1YgYW2YgY';...
        {'Winding1Connection','Yg';'Winding2Connection','Y'},'W1YgYW2YgY';...
        {'Winding1Connection','Y';'Winding2Connection','Yg'},'W1YgYW2YgY';...
        {'Winding1Connection','Y';'Winding2Connection','Y'},'W1YgYW2YgY';...

        {'Winding1Connection','Yg';'Winding2Connection','Yn'},'W1YgYW2Yn';...
        {'Winding1Connection','Y';'Winding2Connection','Yn'},'W1YgYW2Yn';...

        {'Winding1Connection','Yg';'Winding2Connection','Delta (D1)'},'W1YgYW2D1D11';...
        {'Winding1Connection','Yg';'Winding2Connection','Delta (D11)'},'W1YgYW2D1D11';...
        {'Winding1Connection','Y';'Winding2Connection','Delta (D1)'},'W1YgYW2D1D11';...
        {'Winding1Connection','Y';'Winding2Connection','Delta (D11)'},'W1YgYW2D1D11';...


        {'Winding1Connection','Yn';'Winding2Connection','Yg'},'W1YnW2YgY';...
        {'Winding1Connection','Yn';'Winding2Connection','Y'},'W1YnW2YgY';...

        {'Winding1Connection','Yn';'Winding2Connection','Yn'},'W1YnW2Yn';...

        {'Winding1Connection','Yn';'Winding2Connection','Delta (D1)'},'W1YnW2D1D11';...
        {'Winding1Connection','Yn';'Winding2Connection','Delta (D11)'},'W1YnW2D1D11';...


        {'Winding1Connection','Delta (D1)';'Winding2Connection','Yg'},'W1D1D11W2YYg';...
        {'Winding1Connection','Delta (D1)';'Winding2Connection','Y'},'W1D1D11W2YYg';...
        {'Winding1Connection','Delta (D11)';'Winding2Connection','Yg'},'W1D1D11W2YYg';...
        {'Winding1Connection','Delta (D11)';'Winding2Connection','Y'},'W1D1D11W2YYg';...

        {'Winding1Connection','Delta (D1)';'Winding2Connection','Yn'},'W1D1D11W2Yn';...
        {'Winding1Connection','Delta (D11)';'Winding2Connection','Yn'},'W1D1D11W2Yn';...

        {'Winding1Connection','Delta (D1)';'Winding2Connection','Delta (D1)'},'W1D1D11W2D1D11';...
        {'Winding1Connection','Delta (D1)';'Winding2Connection','Delta (D11)'},'W1D1D11W2D1D11';...
        {'Winding1Connection','Delta (D11)';'Winding2Connection','Delta (D1)'},'W1D1D11W2D1D11';...
        {'Winding1Connection','Delta (D11)';'Winding2Connection','Delta (D11)'},'W1D1D11W2D1D11';...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib/Elements/Three-Phase Transformer (Two Windings)'
        NewPath='elec_conv_Three_PhaseTransformer_2/Three_PhaseTransformer_2'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.SRated=ConvClass.mapDirect(obj.OldParam.NominalPower,1);
            obj.NewDirectParam.FRated=ConvClass.mapDirect(obj.OldParam.NominalPower,2);
            obj.NewDirectParam.VRated1=ConvClass.mapDirect(obj.OldParam.Winding1,1);
            obj.NewDirectParam.VRated2=ConvClass.mapDirect(obj.OldParam.Winding2,1);

            if strcmp(obj.OldDropdown.SetSaturation,'on')
                obj.NewDirectParam.phi_specify='on';
                obj.NewDirectParam.phi_priority='high';
            end

        end


        function obj=Three_PhaseTransformer_2_class(Winding1Connection,Winding2Connection,UNITS,...
            NominalPower,Winding1,Winding2,Rm,Lm,L0,...
            Saturation,InitialFluxes,SetSaturation,SetInitialFlux)
            if nargin>0
                obj.OldDropdown.Winding1Connection=Winding1Connection;
                obj.OldDropdown.Winding2Connection=Winding2Connection;
                obj.OldDropdown.UNITS=UNITS;
                obj.OldParam.NominalPower=NominalPower;
                obj.OldParam.Winding1=Winding1;
                obj.OldParam.Winding2=Winding2;
                obj.OldParam.Rm=Rm;
                obj.OldParam.Lm=Lm;
                obj.OldParam.L0=L0;
                obj.OldDropdown.SetSaturation=SetSaturation;
                obj.OldDropdown.SetInitialFlux=SetInitialFlux;
                obj.OldParam.Saturation=Saturation;
                obj.OldParam.InitialFluxes=InitialFluxes;
            end
        end

        function obj=objParamMappingDerived(obj)

            switch obj.OldDropdown.Winding1Connection
            case{'Y','Yn','Yg'}
                xWinding1Connection=ee.enum.Connection.wye;
            case 'Delta (D1)'
                xWinding1Connection=ee.enum.Connection.delta1;
            case 'Delta (D11)'
                xWinding1Connection=ee.enum.Connection.delta11;
            otherwise

            end
            switch obj.OldDropdown.Winding2Connection
            case{'Y','Yn','Yg'}
                xWinding2Connection=ee.enum.Connection.wye;
            case 'Delta (D1)'
                xWinding2Connection=ee.enum.Connection.delta1;
            case 'Delta (D11)'
                xWinding2Connection=ee.enum.Connection.delta11;
            otherwise

            end


            SRated=obj.OldParam.NominalPower(1);
            FRated=obj.OldParam.NominalPower(2);
            VRated1=obj.OldParam.Winding1(1);
            VRated2=obj.OldParam.Winding2(1);
            b=ee.internal.perunit.TransformerBase(SRated,FRated,...
            VRated1,xWinding1Connection,...
            VRated2,xWinding2Connection);

            switch obj.OldDropdown.UNITS
            case 'pu'
                if obj.OldParam.Winding1(2)==0
                    obj.NewDerivedParam.pu_Rw1=1e-6;
                else
                    obj.NewDerivedParam.pu_Rw1=obj.OldParam.Winding1(2);
                end

                if obj.OldParam.Winding1(3)==0
                    obj.NewDerivedParam.pu_Xl1=1e-6;
                else
                    obj.NewDerivedParam.pu_Xl1=obj.OldParam.Winding1(3);
                end

                if obj.OldParam.Winding2(2)==0
                    obj.NewDerivedParam.pu_Rw2=1e-6;
                else
                    obj.NewDerivedParam.pu_Rw2=obj.OldParam.Winding2(2);
                end

                if obj.OldParam.Winding2(3)==0
                    obj.NewDerivedParam.pu_Xl2=1e-6;
                else
                    obj.NewDerivedParam.pu_Xl2=obj.OldParam.Winding2(3);
                end

                if obj.OldParam.Rm==inf
                    obj.NewDerivedParam.pu_Rm=1e6;
                else
                    obj.NewDerivedParam.pu_Rm=obj.OldParam.Rm;
                end

                if obj.OldParam.Lm==inf
                    obj.NewDerivedParam.pu_Xm=1e6;
                else
                    obj.NewDerivedParam.pu_Xm=obj.OldParam.Lm;
                end

                obj.NewDerivedParam.pu_X0=obj.OldParam.L0+obj.NewDerivedParam.pu_Xl1;

                if strcmp(obj.OldDropdown.SetSaturation,'on')
                    obj.NewDerivedParam.current_data=...
                    obj.strictMonoArray(obj.OldParam.Saturation(:,1)');
                    obj.NewDerivedParam.magnetic_flux_data=...
                    obj.strictMonoArray(obj.OldParam.Saturation(:,2)');
                    obj.NewDerivedParam.phi=-obj.OldParam.InitialFluxes;

                end

            case 'SI'

                if obj.OldParam.Winding1(2)==0
                    obj.NewDerivedParam.pu_Rw1=1e-6;
                else
                    obj.NewDerivedParam.pu_Rw1=obj.OldParam.Winding1(2)/b.winding(1).R;
                end

                if obj.OldParam.Winding1(3)==0
                    obj.NewDerivedParam.pu_Xl1=1e-6;
                else
                    obj.NewDerivedParam.pu_Xl1=obj.OldParam.Winding1(3)/b.winding(1).L;
                end

                if obj.OldParam.Winding2(2)==0
                    obj.NewDerivedParam.pu_Rw2=1e-6;
                else
                    obj.NewDerivedParam.pu_Rw2=obj.OldParam.Winding2(2)/b.winding(2).R;
                end

                if obj.OldParam.Winding2(3)==0
                    obj.NewDerivedParam.pu_Xl2=1e-6;
                else
                    obj.NewDerivedParam.pu_Xl2=obj.OldParam.Winding2(3)/b.winding(2).L;
                end

                if obj.OldParam.Rm==inf
                    obj.NewDerivedParam.pu_Rm=1e6;
                else
                    obj.NewDerivedParam.pu_Rm=obj.OldParam.Rm/b.winding(1).R;
                end

                if obj.OldParam.Lm==inf
                    obj.NewDerivedParam.pu_Xm=1e6;
                else
                    obj.NewDerivedParam.pu_Xm=obj.OldParam.Lm/b.winding(1).L;
                end

                obj.NewDerivedParam.pu_X0=obj.OldParam.L0/b.winding(1).L+obj.NewDerivedParam.pu_Xl1;

                if strcmp(obj.OldDropdown.SetSaturation,'on')
                    obj.NewDerivedParam.current_data=...
                    obj.strictMonoArray(obj.OldParam.Saturation(:,1)'/b.winding(1).i);
                    obj.NewDerivedParam.magnetic_flux_data=...
                    obj.strictMonoArray(obj.OldParam.Saturation(:,2)'/b.winding(1).psi);
                    obj.NewDerivedParam.phi=-obj.OldParam.InitialFluxes/b.winding(1).psi;
                end
            end


        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();


            if strcmp(obj.OldDropdown.Hysteresis,'on')
                logObj.addMessage(obj,'CheckboxNotSupported','Simulate hysteresis');
                logObj.addMessage(obj,'CustomMessage','Simulate hysteresis is not supported.');
            end

            if strcmp(obj.OldDropdown.SetSaturation,'on')
                obj.NewDropdown.saturation_option='2';
            else
                obj.NewDropdown.saturation_option='1';
                logObj.addMessage(obj,'CustomMessage','The primary currents might start from undesired values.');
                logObj.addMessage(obj,'CustomMessage','Please make necessary changes in the block ''Variables'' tab or select ''Start simulation from steady state'' in the corresponding ''Solver Configuration'' block.');
            end

            switch obj.OldDropdown.Measurements
            case 'Winding voltages'
                logObj.addMessage(obj,'OptionNotSupported','Measurement','Winding voltages')
            case 'Winding currents'
                logObj.addMessage(obj,'OptionNotSupported','Measurement','Winding currents')
            case 'Fluxes and excitation currents ( Imag + IRm )'
                logObj.addMessage(obj,'OptionNotSupported','Measurement','Fluxes and excitation currents ( Imag + IRm )')
            case 'Fluxes and magnetization currents ( Imag )'
                logObj.addMessage(obj,'OptionNotSupported','Measurement','Fluxes and magnetization currents ( Imag )')
            case 'All measurements (V I Fluxes)'
                logObj.addMessage(obj,'OptionNotSupported','Measurement','All measurements (V I Fluxes)')
            end


            switch obj.OldDropdown.Winding1Connection
            case 'Y'
                obj.NewDropdown.Winding1Connection='1';
            case 'Yn'
                obj.NewDropdown.Winding1Connection='2';
            case 'Yg'
                obj.NewDropdown.Winding1Connection='3';
            case 'Delta (D1)'
                obj.NewDropdown.Winding1Connection='4';
            case 'Delta (D11)'
                obj.NewDropdown.Winding1Connection='5';
            end

            switch obj.OldDropdown.Winding2Connection
            case 'Y'
                obj.NewDropdown.Winding2Connection='1';
            case 'Yn'
                obj.NewDropdown.Winding2Connection='2';
            case 'Yg'
                obj.NewDropdown.Winding2Connection='3';
            case 'Delta (D1)'
                obj.NewDropdown.Winding2Connection='4';
            case 'Delta (D11)'
                obj.NewDropdown.Winding2Connection='5';
            end

            switch obj.OldDropdown.CoreType
            case 'Three-limb core (core-type)'
                obj.NewDropdown.CoreType='1';
            case 'Five-limb core (shell-type)'
                obj.NewDropdown.CoreType='2';
            case 'Three single-phase transformers'
                obj.NewDropdown.CoreType='2';
                logObj.addMessage(obj,'OptionNotSupported','Core Type','Three single-phase transformers')
            end
        end
    end

end
