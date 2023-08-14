classdef Three_PhaseTransformer_1_class<ConvClass&handle



    properties

        OldParam=struct(...
        'NominalPower',[],...
        'VLLnom',[],...
        'WindingResistances',[],...
        'NoLoadIexcPos',[],...
        'NoLoadPlossPos',[],...
        'ShortCircuitReactancePos',[],...
        'ShortCircuitReactancePosAuto',[],...
        'NoLoadIexcZero',[],...
        'NoLoadPlossZero',[],...
        'ShortCircuitReactanceZero',[],...
        'ShortCircuitReactanceZeroAuto',[]...
        )


        OldDropdown=struct(...
        'CoreType',[],...
        'Winding1Connection',[],...
        'Winding2Connection',[],...
        'Measurements',[],...
        'AutoTransformer',[]...
        )


        NewDirectParam=struct(...
        'SRated',[],...
        'FRated',[],...
        'VRated1',[],...
        'VRated2',[]...
        )


        NewDerivedParam=struct(...
        'pu_Rw1',[],...
        'pu_Xl1',[],...
        'pu_Rw2',[],...
        'pu_Xl2',[],...
        'pu_Rm',[],...
        'pu_Xm',[],...
        'pu_X0',[]...
        )


        NewDropdown=struct(...
        'Winding1Connection',[],...
        'Winding2Connection',[],...
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
        OldPath='powerlib/Elements/Three-Phase Transformer Inductance Matrix Type (Two Windings)'
        NewPath='elec_conv_Three_PhaseTransformer_1/Three_PhaseTransformer_1'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.SRated=ConvClass.mapDirect(obj.OldParam.NominalPower,1);
            obj.NewDirectParam.FRated=ConvClass.mapDirect(obj.OldParam.NominalPower,2);
            obj.NewDirectParam.VRated1=ConvClass.mapDirect(obj.OldParam.VLLnom,1);
            obj.NewDirectParam.VRated2=ConvClass.mapDirect(obj.OldParam.VLLnom,2);
        end


        function obj=Three_PhaseTransformer_1_class(Winding1Connection,Winding2Connection,NominalPower,VLLnom,WindingResistances,...
            NoLoadPlossPos,NoLoadIexcPos,ShortCircuitReactancePos,...
            NoLoadIexcZero,NoLoadPlossZero,ShortCircuitReactanceZero)
            if nargin>0
                obj.OldDropdown.Winding1Connection=Winding1Connection;
                obj.OldDropdown.Winding2Connection=Winding2Connection;
                obj.OldParam.NominalPower=NominalPower;
                obj.OldParam.VLLnom=VLLnom;
                obj.OldParam.WindingResistances=WindingResistances;
                obj.OldParam.NoLoadPlossPos=NoLoadPlossPos;
                obj.OldParam.NoLoadIexcPos=NoLoadIexcPos;
                obj.OldParam.ShortCircuitReactancePos=ShortCircuitReactancePos;
                obj.OldParam.NoLoadPlossZero=NoLoadPlossZero;
                obj.OldParam.NoLoadIexcZero=NoLoadIexcZero;
                obj.OldParam.ShortCircuitReactanceZero=ShortCircuitReactanceZero;
            end
        end

        function obj=objParamMappingDerived(obj)


            if obj.OldParam.WindingResistances(1)==0
                obj.NewDerivedParam.pu_Rw1=1e-6;
            else
                obj.NewDerivedParam.pu_Rw1=obj.OldParam.WindingResistances(1);
            end

            if obj.OldParam.WindingResistances(2)==0
                obj.NewDerivedParam.pu_Rw2=1e-6;
            else
                obj.NewDerivedParam.pu_Rw2=obj.OldParam.WindingResistances(2);
            end

            SRated=obj.OldParam.NominalPower(1);


            P1_pu=obj.OldParam.NoLoadPlossPos/SRated;
            I1_pu=obj.OldParam.NoLoadIexcPos/100;
            P1core_pu=P1_pu-I1_pu^2*obj.NewDerivedParam.pu_Rw1;
            Rm_pu=1/P1core_pu;
            Q1_pu=sqrt(I1_pu^2-P1_pu^2);
            Xs1_pu=1/Q1_pu;
            Xs2_pu=1/Q1_pu;
            X121_pu=obj.OldParam.ShortCircuitReactancePos;
            Xm_pu=sqrt(Xs2_pu*(Xs1_pu-X121_pu));
            obj.NewDerivedParam.pu_Rm=Rm_pu;
            obj.NewDerivedParam.pu_Xm=Xm_pu;


            P0_pu=obj.OldParam.NoLoadPlossZero/SRated;
            I0_pu=obj.OldParam.NoLoadIexcZero/100;


            Q0_pu=sqrt(I0_pu^2-P0_pu^2);
            X120_pu=obj.OldParam.ShortCircuitReactanceZero;
            X0_pu=sqrt((1/Q0_pu)*((1/Q0_pu)-X120_pu));





            X1_pu_0=((X121_pu+X120_pu)-sqrt((X121_pu-X120_pu)^2+4*X0_pu*(X121_pu-X120_pu)))/2;
            X2_pu_0=X121_pu-X1_pu_0;




            R2_pu=obj.NewDerivedParam.pu_Rw2;
            Coef2=(Rm_pu^2*X0_pu^2*X120_pu-Rm_pu^2*X0_pu^2*X121_pu+Rm_pu^2*X0_pu*Xm_pu^2+Rm_pu^2*X0_pu^2*Xm_pu+Rm_pu^2*X120_pu*Xm_pu^2-Rm_pu^2*X121_pu*Xm_pu^2+X0_pu^2*X120_pu*Xm_pu^2-X0_pu^2*X121_pu*Xm_pu^2+2*Rm_pu^2*X0_pu*X120_pu*Xm_pu-2*Rm_pu^2*X0_pu*X121_pu*Xm_pu)/...
            (Rm_pu^2*X0_pu^2+Rm_pu^2*Xm_pu^2+X0_pu^2*Xm_pu^2+2*Rm_pu^2*X0_pu*Xm_pu);
            Coef1=(R2_pu^2*Rm_pu^2*X0_pu^2+R2_pu^2*Rm_pu^2*Xm_pu^2+R2_pu^2*X0_pu^2*Xm_pu^2+2*R2_pu*Rm_pu*X0_pu^2*Xm_pu^2+2*R2_pu^2*Rm_pu^2*X0_pu*Xm_pu+2*Rm_pu^2*X0_pu*X120_pu*Xm_pu^2+2*Rm_pu^2*X0_pu^2*X120_pu*Xm_pu-2*Rm_pu^2*X0_pu*X121_pu*Xm_pu^2-2*Rm_pu^2*X0_pu^2*X121_pu*Xm_pu)/...
            (Rm_pu^2*X0_pu^2+Rm_pu^2*Xm_pu^2+X0_pu^2*Xm_pu^2+2*Rm_pu^2*X0_pu*Xm_pu);
            Coef0=-(-R2_pu^2*Rm_pu^2*X0_pu^2*X120_pu+R2_pu^2*Rm_pu^2*X0_pu^2*X121_pu+R2_pu^2*Rm_pu^2*X0_pu*Xm_pu^2+R2_pu^2*Rm_pu^2*X0_pu^2*Xm_pu-R2_pu^2*Rm_pu^2*X120_pu*Xm_pu^2+R2_pu^2*Rm_pu^2*X121_pu*Xm_pu^2-R2_pu^2*X0_pu^2*X120_pu*Xm_pu^2+R2_pu^2*X0_pu^2*X121_pu*Xm_pu^2-Rm_pu^2*X0_pu^2*X120_pu*Xm_pu^2+Rm_pu^2*X0_pu^2*X121_pu*Xm_pu^2-2*R2_pu*Rm_pu*X0_pu^2*X120_pu*Xm_pu^2-2*R2_pu^2*Rm_pu^2*X0_pu*X120_pu*Xm_pu+2*R2_pu*Rm_pu*X0_pu^2*X121_pu*Xm_pu^2+2*R2_pu^2*Rm_pu^2*X0_pu*X121_pu*Xm_pu)/...
            (Rm_pu^2*X0_pu^2+Rm_pu^2*Xm_pu^2+X0_pu^2*Xm_pu^2+2*Rm_pu^2*X0_pu*Xm_pu);

            X2_pu_vec=roots([1,Coef2,Coef1,Coef0]);
            X1_pu_vec=X121_pu-X2_pu_vec;
            [~,SolutionIndex]=min(abs(X2_pu_vec-X2_pu_0));
            X1_pu=X1_pu_vec(SolutionIndex);
            X2_pu=X2_pu_vec(SolutionIndex);


            if X1_pu<0||X2_pu<0
                X1_pu=X121_pu/2;
                X2_pu=X121_pu/2;
            end

            obj.NewDerivedParam.pu_Xl1=X1_pu;
            obj.NewDerivedParam.pu_Xl2=X2_pu;
            obj.NewDerivedParam.pu_X0=X0_pu+obj.NewDerivedParam.pu_Xl1;


        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();

            logObj.addMessage(obj,'CustomMessage','The primary currents might start from undesired values.');
            logObj.addMessage(obj,'CustomMessage','Please make necessary changes in the block ''Variables'' tab or select ''Start simulation from steady state'' in the corresponding ''Solver Configuration'' block.');


            if strcmp(obj.OldDropdown.AutoTransformer,'on')
                logObj.addMessage(obj,'CheckboxNotSupported','Connect windings 1 and 2 in autotransformer (Y, Yn, or Yg)');
            end

            switch obj.OldDropdown.Measurements
            case 'Winding voltages'
                logObj.addMessage(obj,'OptionNotSupported','Measurement','Winding voltages');
            case 'Winding currents'
                logObj.addMessage(obj,'OptionNotSupported','Measurement','Winding currents');
            case 'All measurements'
                logObj.addMessage(obj,'OptionNotSupported','Measurement','All measurements');
            end

            switch obj.OldDropdown.CoreType
            case 'Three-limb or five-limb core'
                obj.NewDropdown.CoreType='1';
            case 'Three single-phase cores'
                obj.NewDropdown.CoreType='2';
                logObj.addMessage(obj,'OptionNotSupported','Core Type','Three single-phase transformers');
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
        end
    end

end

