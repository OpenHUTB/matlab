classdef Three_PhaseTransformerIn_class<ConvClass&handle



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
        'Winding3Connection',[],...
        'Measurements',[],...
        'AutoTransformer',[],...
        'X12ZeroMeasuredWithW3Delta',[]...
        )


        NewDirectParam=struct(...
        'SRated',[],...
        'FRated',[],...
        'VRated1',[]...
        )


        NewDerivedParam=struct(...
        'VRated2',[],...
        'VRated3',[],...
        'pu_Rw1',[],...
        'pu_Xl1',[],...
        'pu_Rw2',[],...
        'pu_Xl2',[],...
        'pu_Rw3',[],...
        'pu_Xl3',[],...
        'pu_Rm',[],...
        'pu_Xm',[],...
        'pu_X0',[]...
        )


        NewDropdown=struct(...
        'CoreType',[],...
        'Winding1Connection',[],...
        'Winding2Connection',[],...
        'Winding3Connection',[]...
        )


        BlockOption={...

        {'Winding1Connection','Yg';'Winding2Connection','Yg';'Winding3Connection','Yg'},'W1YgYW2YgYW3YgY';...
        {'Winding1Connection','Yg';'Winding2Connection','Y';'Winding3Connection','Yg'},'W1YgYW2YgYW3YgY';...
        {'Winding1Connection','Y';'Winding2Connection','Yg';'Winding3Connection','Yg'},'W1YgYW2YgYW3YgY';...
        {'Winding1Connection','Y';'Winding2Connection','Y';'Winding3Connection','Yg'},'W1YgYW2YgYW3YgY';...
        {'Winding1Connection','Yg';'Winding2Connection','Yg';'Winding3Connection','Y'},'W1YgYW2YgYW3YgY';...
        {'Winding1Connection','Yg';'Winding2Connection','Y';'Winding3Connection','Y'},'W1YgYW2YgYW3YgY';...
        {'Winding1Connection','Y';'Winding2Connection','Yg';'Winding3Connection','Y'},'W1YgYW2YgYW3YgY';...
        {'Winding1Connection','Y';'Winding2Connection','Y';'Winding3Connection','Y'},'W1YgYW2YgYW3YgY';...

        {'Winding1Connection','Yg';'Winding2Connection','Yg';'Winding3Connection','Yn'},'W1YgYW2YgYW3Yn';...
        {'Winding1Connection','Yg';'Winding2Connection','Y';'Winding3Connection','Yn'},'W1YgYW2YgYW3Yn';...
        {'Winding1Connection','Y';'Winding2Connection','Yg';'Winding3Connection','Yn'},'W1YgYW2YgYW3Yn';...
        {'Winding1Connection','Y';'Winding2Connection','Y';'Winding3Connection','Yn'},'W1YgYW2YgYW3Yn';...

        {'Winding1Connection','Yg';'Winding2Connection','Yg';'Winding3Connection','Delta (D1)'},'W1YgYW2YgYW3D1D11';...
        {'Winding1Connection','Yg';'Winding2Connection','Y';'Winding3Connection','Delta (D1)'},'W1YgYW2YgYW3D1D11';...
        {'Winding1Connection','Y';'Winding2Connection','Yg';'Winding3Connection','Delta (D1)'},'W1YgYW2YgYW3D1D11';...
        {'Winding1Connection','Y';'Winding2Connection','Y';'Winding3Connection','Delta (D1)'},'W1YgYW2YgYW3D1D11';...
        {'Winding1Connection','Yg';'Winding2Connection','Yg';'Winding3Connection','Delta (D11)'},'W1YgYW2YgYW3D1D11';...
        {'Winding1Connection','Yg';'Winding2Connection','Y';'Winding3Connection','Delta (D11)'},'W1YgYW2YgYW3D1D11';...
        {'Winding1Connection','Y';'Winding2Connection','Yg';'Winding3Connection','Delta (D11)'},'W1YgYW2YgYW3D1D11';...
        {'Winding1Connection','Y';'Winding2Connection','Y';'Winding3Connection','Delta (D11)'},'W1YgYW2YgYW3D1D11';...




        {'Winding1Connection','Yg';'Winding2Connection','Yn';'Winding3Connection','Yg'},'W1YgYW2YnW3YgY';...
        {'Winding1Connection','Y';'Winding2Connection','Yn';'Winding3Connection','Yg'},'W1YgYW2YnW3YgY';...
        {'Winding1Connection','Yg';'Winding2Connection','Yn';'Winding3Connection','Y'},'W1YgYW2YnW3YgY';...
        {'Winding1Connection','Y';'Winding2Connection','Yn';'Winding3Connection','Y'},'W1YgYW2YnW3YgY';...

        {'Winding1Connection','Yg';'Winding2Connection','Yn';'Winding3Connection','Yn'},'W1YgYW2YnW3Yn';...
        {'Winding1Connection','Y';'Winding2Connection','Yn';'Winding3Connection','Yn'},'W1YgYW2YnW3Yn';...

        {'Winding1Connection','Yg';'Winding2Connection','Yn';'Winding3Connection','Delta (D1)'},'W1YgYW2YnW3D1D11';...
        {'Winding1Connection','Y';'Winding2Connection','Yn';'Winding3Connection','Delta (D1)'},'W1YgYW2YnW3D1D11';...
        {'Winding1Connection','Yg';'Winding2Connection','Yn';'Winding3Connection','Delta (D11)'},'W1YgYW2YnW3D1D11';...
        {'Winding1Connection','Y';'Winding2Connection','Yn';'Winding3Connection','Delta (D11)'},'W1YgYW2YnW3D1D11';...




        {'Winding1Connection','Yg';'Winding2Connection','Delta (D1)';'Winding3Connection','Yg'},'W1YgYW2D1D11W3YgY';...
        {'Winding1Connection','Yg';'Winding2Connection','Delta (D11)';'Winding3Connection','Yg'},'W1YgYW2D1D11W3YgY';...
        {'Winding1Connection','Y';'Winding2Connection','Delta (D1)';'Winding3Connection','Yg'},'W1YgYW2D1D11W3YgY';...
        {'Winding1Connection','Y';'Winding2Connection','Delta (D11)';'Winding3Connection','Yg'},'W1YgYW2D1D11W3YgY';...
        {'Winding1Connection','Yg';'Winding2Connection','Delta (D1)';'Winding3Connection','Y'},'W1YgYW2D1D11W3YgY';...
        {'Winding1Connection','Yg';'Winding2Connection','Delta (D11)';'Winding3Connection','Y'},'W1YgYW2D1D11W3YgY';...
        {'Winding1Connection','Y';'Winding2Connection','Delta (D1)';'Winding3Connection','Y'},'W1YgYW2D1D11W3YgY';...
        {'Winding1Connection','Y';'Winding2Connection','Delta (D11)';'Winding3Connection','Y'},'W1YgYW2D1D11W3YgY';...

        {'Winding1Connection','Yg';'Winding2Connection','Delta (D1)';'Winding3Connection','Yn'},'W1YgYW2D1D11W3Yn';...
        {'Winding1Connection','Yg';'Winding2Connection','Delta (D11)';'Winding3Connection','Yn'},'W1YgYW2D1D11W3Yn';...
        {'Winding1Connection','Y';'Winding2Connection','Delta (D1)';'Winding3Connection','Yn'},'W1YgYW2D1D11W3Yn';...
        {'Winding1Connection','Y';'Winding2Connection','Delta (D11)';'Winding3Connection','Yn'},'W1YgYW2D1D11W3Yn';...

        {'Winding1Connection','Yg';'Winding2Connection','Delta (D1)';'Winding3Connection','Delta (D1)'},'W1YgYW2D1D11W3D1D11';...
        {'Winding1Connection','Yg';'Winding2Connection','Delta (D11)';'Winding3Connection','Delta (D1)'},'W1YgYW2D1D11W3D1D11';...
        {'Winding1Connection','Y';'Winding2Connection','Delta (D1)';'Winding3Connection','Delta (D1)'},'W1YgYW2D1D11W3D1D11';...
        {'Winding1Connection','Y';'Winding2Connection','Delta (D11)';'Winding3Connection','Delta (D1)'},'W1YgYW2D1D11W3D1D11';...
        {'Winding1Connection','Yg';'Winding2Connection','Delta (D1)';'Winding3Connection','Delta (D11)'},'W1YgYW2D1D11W3D1D11';...
        {'Winding1Connection','Yg';'Winding2Connection','Delta (D11)';'Winding3Connection','Delta (D11)'},'W1YgYW2D1D11W3D1D11';...
        {'Winding1Connection','Y';'Winding2Connection','Delta (D1)';'Winding3Connection','Delta (D11)'},'W1YgYW2D1D11W3D1D11';...
        {'Winding1Connection','Y';'Winding2Connection','Delta (D11)';'Winding3Connection','Delta (D11)'},'W1YgYW2D1D11W3D1D11';...




        {'Winding1Connection','Yn';'Winding2Connection','Yg';'Winding3Connection','Yg'},'W1YnW2YgYW3YgY';...
        {'Winding1Connection','Yn';'Winding2Connection','Y';'Winding3Connection','Yg'},'W1YnW2YgYW3YgY';...
        {'Winding1Connection','Yn';'Winding2Connection','Yg';'Winding3Connection','Y'},'W1YnW2YgYW3YgY';...
        {'Winding1Connection','Yn';'Winding2Connection','Y';'Winding3Connection','Y'},'W1YnW2YgYW3YgY';...

        {'Winding1Connection','Yn';'Winding2Connection','Yg';'Winding3Connection','Yn'},'W1YnW2YgYW3Yn';...
        {'Winding1Connection','Yn';'Winding2Connection','Y';'Winding3Connection','Yn'},'W1YnW2YgYW3Yn';...

        {'Winding1Connection','Yn';'Winding2Connection','Yg';'Winding3Connection','Delta (D1)'},'W1YnW2YgYW3D1D11';...
        {'Winding1Connection','Yn';'Winding2Connection','Y';'Winding3Connection','Delta (D1)'},'W1YnW2YgYW3D1D11';...
        {'Winding1Connection','Yn';'Winding2Connection','Yg';'Winding3Connection','Delta (D11)'},'W1YnW2YgYW3D1D11';...
        {'Winding1Connection','Yn';'Winding2Connection','Y';'Winding3Connection','Delta (D11)'},'W1YnW2YgYW3D1D11';...




        {'Winding1Connection','Yn';'Winding2Connection','Yn';'Winding3Connection','Yg'},'W1YnW2YnW3YgY';...
        {'Winding1Connection','Yn';'Winding2Connection','Yn';'Winding3Connection','Y'},'W1YnW2YnW3YgY';...

        {'Winding1Connection','Yn';'Winding2Connection','Yn';'Winding3Connection','Yn'},'W1YnW2YnW3Yn';...

        {'Winding1Connection','Yn';'Winding2Connection','Yn';'Winding3Connection','Delta (D1)'},'W1YnW2YnW3D1D11';...
        {'Winding1Connection','Yn';'Winding2Connection','Yn';'Winding3Connection','Delta (D11)'},'W1YnW2YnW3D1D11';...




        {'Winding1Connection','Yn';'Winding2Connection','Delta (D1)';'Winding3Connection','Yg'},'W1YnW2D1D11W3YgY';...
        {'Winding1Connection','Yn';'Winding2Connection','Delta (D11)';'Winding3Connection','Yg'},'W1YnW2D1D11W3YgY';...
        {'Winding1Connection','Yn';'Winding2Connection','Delta (D1)';'Winding3Connection','Y'},'W1YnW2D1D11W3YgY';...
        {'Winding1Connection','Yn';'Winding2Connection','Delta (D11)';'Winding3Connection','Y'},'W1YnW2D1D11W3YgY';...

        {'Winding1Connection','Yn';'Winding2Connection','Delta (D1)';'Winding3Connection','Yn'},'W1YnW2D1D11W3Yn';...
        {'Winding1Connection','Yn';'Winding2Connection','Delta (D11)';'Winding3Connection','Yn'},'W1YnW2D1D11W3Yn';...

        {'Winding1Connection','Yn';'Winding2Connection','Delta (D1)';'Winding3Connection','Delta (D1)'},'W1YnW2D1D11W3D1D11';...
        {'Winding1Connection','Yn';'Winding2Connection','Delta (D11)';'Winding3Connection','Delta (D1)'},'W1YnW2D1D11W3D1D11';...
        {'Winding1Connection','Yn';'Winding2Connection','Delta (D1)';'Winding3Connection','Delta (D11)'},'W1YnW2D1D11W3D1D11';...
        {'Winding1Connection','Yn';'Winding2Connection','Delta (D11)';'Winding3Connection','Delta (D11)'},'W1YnW2D1D11W3D1D11';...




        {'Winding1Connection','Delta (D1)';'Winding2Connection','Yg';'Winding3Connection','Yg'},'W1D1D11W2YgYW3YgY';...
        {'Winding1Connection','Delta (D1)';'Winding2Connection','Y';'Winding3Connection','Yg'},'W1D1D11W2YgYW3YgY';...
        {'Winding1Connection','Delta (D11)';'Winding2Connection','Yg';'Winding3Connection','Yg'},'W1D1D11W2YgYW3YgY';...
        {'Winding1Connection','Delta (D11)';'Winding2Connection','Y';'Winding3Connection','Yg'},'W1D1D11W2YgYW3YgY';...
        {'Winding1Connection','Delta (D1)';'Winding2Connection','Yg';'Winding3Connection','Y'},'W1D1D11W2YgYW3YgY';...
        {'Winding1Connection','Delta (D1)';'Winding2Connection','Y';'Winding3Connection','Y'},'W1D1D11W2YgYW3YgY';...
        {'Winding1Connection','Delta (D11)';'Winding2Connection','Yg';'Winding3Connection','Y'},'W1D1D11W2YgYW3YgY';...
        {'Winding1Connection','Delta (D11)';'Winding2Connection','Y';'Winding3Connection','Y'},'W1D1D11W2YgYW3YgY';...

        {'Winding1Connection','Delta (D1)';'Winding2Connection','Yg';'Winding3Connection','Yn'},'W1D1D11W2YgYW3Yn';...
        {'Winding1Connection','Delta (D1)';'Winding2Connection','Y';'Winding3Connection','Yn'},'W1D1D11W2YgYW3Yn';...
        {'Winding1Connection','Delta (D11)';'Winding2Connection','Yg';'Winding3Connection','Yn'},'W1D1D11W2YgYW3Yn';...
        {'Winding1Connection','Delta (D11)';'Winding2Connection','Y';'Winding3Connection','Yn'},'W1D1D11W2YgYW3Yn';...

        {'Winding1Connection','Delta (D1)';'Winding2Connection','Yg';'Winding3Connection','Delta (D1)'},'W1D1D11W2YgYW3D1D11';...
        {'Winding1Connection','Delta (D1)';'Winding2Connection','Y';'Winding3Connection','Delta (D1)'},'W1D1D11W2YgYW3D1D11';...
        {'Winding1Connection','Delta (D11)';'Winding2Connection','Yg';'Winding3Connection','Delta (D1)'},'W1D1D11W2YgYW3D1D11';...
        {'Winding1Connection','Delta (D11)';'Winding2Connection','Y';'Winding3Connection','Delta (D1)'},'W1D1D11W2YgYW3D1D11';...
        {'Winding1Connection','Delta (D1)';'Winding2Connection','Yg';'Winding3Connection','Delta (D11)'},'W1D1D11W2YgYW3D1D11';...
        {'Winding1Connection','Delta (D1)';'Winding2Connection','Y';'Winding3Connection','Delta (D11)'},'W1D1D11W2YgYW3D1D11';...
        {'Winding1Connection','Delta (D11)';'Winding2Connection','Yg';'Winding3Connection','Delta (D11)'},'W1D1D11W2YgYW3D1D11';...
        {'Winding1Connection','Delta (D11)';'Winding2Connection','Y';'Winding3Connection','Delta (D11)'},'W1D1D11W2YgYW3D1D11';...




        {'Winding1Connection','Delta (D1)';'Winding2Connection','Yn';'Winding3Connection','Yg'},'W1D1D11W2YnW3YgY';...
        {'Winding1Connection','Delta (D11)';'Winding2Connection','Yn';'Winding3Connection','Yg'},'W1D1D11W2YnW3YgY';...
        {'Winding1Connection','Delta (D1)';'Winding2Connection','Yn';'Winding3Connection','Y'},'W1D1D11W2YnW3YgY';...
        {'Winding1Connection','Delta (D11)';'Winding2Connection','Yn';'Winding3Connection','Y'},'W1D1D11W2YnW3YgY';...

        {'Winding1Connection','Delta (D1)';'Winding2Connection','Yn';'Winding3Connection','Yn'},'W1D1D11W2YnW3Yn';...
        {'Winding1Connection','Delta (D11)';'Winding2Connection','Yn';'Winding3Connection','Yn'},'W1D1D11W2YnW3Yn';...

        {'Winding1Connection','Delta (D1)';'Winding2Connection','Yn';'Winding3Connection','Delta (D1)'},'W1D1D11W2YnW3D1D11';...
        {'Winding1Connection','Delta (D11)';'Winding2Connection','Yn';'Winding3Connection','Delta (D1)'},'W1D1D11W2YnW3D1D11';...
        {'Winding1Connection','Delta (D1)';'Winding2Connection','Yn';'Winding3Connection','Delta (D11)'},'W1D1D11W2YnW3D1D11';...
        {'Winding1Connection','Delta (D11)';'Winding2Connection','Yn';'Winding3Connection','Delta (D11)'},'W1D1D11W2YnW3D1D11';...




        {'Winding1Connection','Delta (D1)';'Winding2Connection','Delta (D1)';'Winding3Connection','Yg'},'W1D1D11W2D1D11W3YgY';...
        {'Winding1Connection','Delta (D1)';'Winding2Connection','Delta (D11)';'Winding3Connection','Yg'},'W1D1D11W2D1D11W3YgY';...
        {'Winding1Connection','Delta (D11)';'Winding2Connection','Delta (D1)';'Winding3Connection','Yg'},'W1D1D11W2D1D11W3YgY';...
        {'Winding1Connection','Delta (D11)';'Winding2Connection','Delta (D11)';'Winding3Connection','Yg'},'W1D1D11W2D1D11W3YgY';...
        {'Winding1Connection','Delta (D1)';'Winding2Connection','Delta (D1)';'Winding3Connection','Y'},'W1D1D11W2D1D11W3YgY';...
        {'Winding1Connection','Delta (D1)';'Winding2Connection','Delta (D11)';'Winding3Connection','Y'},'W1D1D11W2D1D11W3YgY';...
        {'Winding1Connection','Delta (D11)';'Winding2Connection','Delta (D1)';'Winding3Connection','Y'},'W1D1D11W2D1D11W3YgY';...
        {'Winding1Connection','Delta (D11)';'Winding2Connection','Delta (D11)';'Winding3Connection','Y'},'W1D1D11W2D1D11W3YgY';...

        {'Winding1Connection','Delta (D1)';'Winding2Connection','Delta (D1)';'Winding3Connection','Yn'},'W1D1D11W2D1D11W3Yn';...
        {'Winding1Connection','Delta (D1)';'Winding2Connection','Delta (D11)';'Winding3Connection','Yn'},'W1D1D11W2D1D11W3Yn';...
        {'Winding1Connection','Delta (D11)';'Winding2Connection','Delta (D1)';'Winding3Connection','Yn'},'W1D1D11W2D1D11W3Yn';...
        {'Winding1Connection','Delta (D11)';'Winding2Connection','Delta (D11)';'Winding3Connection','Yn'},'W1D1D11W2D1D11W3Yn';...

        {'Winding1Connection','Delta (D1)';'Winding2Connection','Delta (D1)';'Winding3Connection','Delta (D1)'},'W1D1D11W2D1D11W3D1D11';...
        {'Winding1Connection','Delta (D1)';'Winding2Connection','Delta (D11)';'Winding3Connection','Delta (D1)'},'W1D1D11W2D1D11W3D1D11';...
        {'Winding1Connection','Delta (D11)';'Winding2Connection','Delta (D1)';'Winding3Connection','Delta (D1)'},'W1D1D11W2D1D11W3D1D11';...
        {'Winding1Connection','Delta (D11)';'Winding2Connection','Delta (D11)';'Winding3Connection','Delta (D1)'},'W1D1D11W2D1D11W3D1D11';...
        {'Winding1Connection','Delta (D1)';'Winding2Connection','Delta (D1)';'Winding3Connection','Delta (D11)'},'W1D1D11W2D1D11W3D1D11';...
        {'Winding1Connection','Delta (D1)';'Winding2Connection','Delta (D11)';'Winding3Connection','Delta (D11)'},'W1D1D11W2D1D11W3D1D11';...
        {'Winding1Connection','Delta (D11)';'Winding2Connection','Delta (D1)';'Winding3Connection','Delta (D11)'},'W1D1D11W2D1D11W3D1D11';...
        {'Winding1Connection','Delta (D11)';'Winding2Connection','Delta (D11)';'Winding3Connection','Delta (D11)'},'W1D1D11W2D1D11W3D1D11';...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib/Elements/Three-Phase Transformer Inductance Matrix Type (Three Windings)'
        NewPath='elec_conv_Three_PhaseTransformerIn/Three_PhaseTransformerIn'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.SRated=ConvClass.mapDirect(obj.OldParam.NominalPower,1);
            obj.NewDirectParam.FRated=ConvClass.mapDirect(obj.OldParam.NominalPower,2);
            obj.NewDirectParam.VRated1=ConvClass.mapDirect(obj.OldParam.VLLnom,1);
        end


        function obj=Three_PhaseTransformerIn_class(Winding1Connection,Winding2Connection,Winding3Connection,X12ZeroMeasuredWithW3Delta,...
            NominalPower,VLLnom,WindingResistances,...
            NoLoadPlossPos,NoLoadIexcPos,ShortCircuitReactancePos,...
            NoLoadPlossZero,NoLoadIexcZero,ShortCircuitReactanceZero)
            if nargin>0
                obj.OldDropdown.Winding1Connection=Winding1Connection;
                obj.OldDropdown.Winding2Connection=Winding2Connection;
                obj.OldDropdown.Winding3Connection=Winding3Connection;
                obj.OldDropdown.X12ZeroMeasuredWithW3Delta=X12ZeroMeasuredWithW3Delta;
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


            SRated=obj.OldParam.NominalPower(1);
            FRated=obj.OldParam.NominalPower(2);
            VRated1=obj.OldParam.VLLnom(1);
            VRated2=obj.OldParam.VLLnom(2);
            VRated3=obj.OldParam.VLLnom(3);

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

            if obj.OldParam.WindingResistances(3)==0
                obj.NewDerivedParam.pu_Rw3=1e-6;
            else
                obj.NewDerivedParam.pu_Rw3=obj.OldParam.WindingResistances(3);
            end


            P1_pu=obj.OldParam.NoLoadPlossPos/SRated;
            I1_pu=obj.OldParam.NoLoadIexcPos/100;
            X121_pu=obj.OldParam.ShortCircuitReactancePos(1);
            X131_pu=obj.OldParam.ShortCircuitReactancePos(2);
            X231_pu=obj.OldParam.ShortCircuitReactancePos(3);

            P1core_pu=P1_pu-I1_pu^2*obj.NewDerivedParam.pu_Rw1;
            Q1_pu=sqrt(I1_pu^2-P1_pu^2);
            Rm_pu=1/P1core_pu;
            obj.NewDerivedParam.pu_Rm=Rm_pu;
            Xs1_pu=1/Q1_pu;
            Xs2_pu=1/Q1_pu;
            Xs3_pu=1/Q1_pu;
            Xm12_pu=sqrt(Xs2_pu*(Xs1_pu-X121_pu));
            Xm13_pu=sqrt(Xs3_pu*(Xs1_pu-X131_pu));
            Xm23_pu=sqrt(Xs3_pu*(Xs2_pu-X231_pu));
            Xm_pu=(Xm12_pu+Xm13_pu+Xm23_pu)/3;
            X1_pu=0.5*(X121_pu+X131_pu+X231_pu)-X231_pu;
            X2_pu=0.5*(X121_pu+X131_pu+X231_pu)-X131_pu;
            X3_pu=0.5*(X121_pu+X131_pu+X231_pu)-X121_pu;

            if min([X1_pu,X2_pu,X3_pu])>0
                obj.NewDerivedParam.pu_Xl1=X1_pu;
                obj.NewDerivedParam.pu_Xl2=X2_pu;
                obj.NewDerivedParam.pu_Xl3=X3_pu;
                obj.NewDerivedParam.pu_Xm=Xm_pu;
                obj.NewDerivedParam.VRated2=VRated2;
                obj.NewDerivedParam.VRated3=VRated3;

            else



                switch obj.OldDropdown.Winding1Connection
                case{'Y','Yn','Yg'}
                    xWinding1Connection=ee.enum.Connection.wye;
                otherwise
                    xWinding1Connection=ee.enum.Connection.delta;
                end
                switch obj.OldDropdown.Winding2Connection
                case{'Y','Yn','Yg'}
                    xWinding2Connection=ee.enum.Connection.wye;
                otherwise
                    xWinding2Connection=ee.enum.Connection.delta;
                end
                switch obj.OldDropdown.Winding3Connection
                case{'Y','Yn','Yg'}
                    xWinding3Connection=ee.enum.Connection.wye;
                otherwise
                    xWinding3Connection=ee.enum.Connection.delta;
                end


                if(xWinding1Connection==1&&xWinding2Connection==1)||...
                    (xWinding1Connection==2&&xWinding2Connection==2)
                    N21=VRated2/VRated1;
                elseif xWinding1Connection==1&&xWinding2Connection==2
                    N21=(VRated2/VRated1)*sqrt(3);
                else
                    N21=(VRated2/VRated1)/sqrt(3);
                end


                if(xWinding1Connection==1&&xWinding3Connection==1)||...
                    (xWinding1Connection==2&&xWinding3Connection==2)
                    N31=VRated3/VRated1;
                elseif xWinding1Connection==1&&xWinding3Connection==2
                    N31=(VRated3/VRated1)*sqrt(3);
                else
                    N31=(VRated3/VRated1)/sqrt(3);
                end



                b=ee.internal.perunit.TransformerBase(SRated,FRated,VRated1,xWinding1Connection,VRated2,xWinding2Connection,VRated3,xWinding3Connection);
                L1=b.winding(1).L*X1_pu;
                L2=b.winding(2).L*X2_pu;
                L3=b.winding(3).L*X3_pu;
                Lm=b.winding(1).L*Xm_pu;

                Ls1=L1+Lm;
                Ls2=L2+Lm*N21^2;
                Ls3=L3+Lm*N31^2;
                Lm12=Lm*N21;
                Lm13=Lm*N31;
                Lm23=Lm*N21*N31;

                N2N1_max=Ls2/Lm12;
                N2N1_min=Lm12/Ls1;
                N3N1_max=Ls3/Lm13;
                N3N1_min=Lm13/Ls1;
                N3N2_max=Ls3/Lm23;
                N3N2_min=Lm23/Ls2;

                [~,I]=sort([X1_pu,X2_pu,X3_pu]);
                Min=num2str(I(1));
                Max=num2str(I(3));

                if(strcmp(Min,'1')&&strcmp(Max,'2'))||(strcmp(Min,'2')&&strcmp(Max,'1'))

                    if strcmp(Min,'1')
                        N21_new=N2N1_min+(N2N1_max-N2N1_min)*0.02;
                    else
                        N21_new=N2N1_max-(N2N1_max-N2N1_min)*0.02;
                    end

                    Lm_new=Lm12/N21_new;
                    L1_new=Ls1-Lm_new;
                    L2_new=Ls2-Lm_new*N21_new^2;
                    N31_new=Lm23/(Lm_new*N21_new);
                    L3_new=Ls3-Lm_new*N31_new^2;


                elseif strcmp(Min,'1')&&strcmp(Max,'3')||strcmp(Min,'3')&&strcmp(Max,'1')

                    if strcmp(Min,'1')
                        N31_new=N3N1_min+(N3N1_max-N3N1_min)*0.02;
                    else
                        N31_new=N3N1_max-(N3N1_max-N3N1_min)*0.02;
                    end

                    Lm_new=Lm13/N31_new;
                    L1_new=Ls1-Lm_new;
                    L3_new=Ls3-Lm_new*N31_new^2;
                    N21_new=Lm23/(Lm_new*N31_new);
                    L2_new=Ls2-Lm_new*N21_new^2;


                else

                    if strcmp(Min,'2')
                        N32_new=N3N2_min+(N3N2_max-N3N2_min)*0.02;
                    else
                        N32_new=N3N2_max-(N3N2_max-N3N2_min)*0.02;
                    end



                    N31_new=N31;
                    N21_new=N31_new/N32_new;

                    Lm_new=Lm23/(N21_new*N31_new);
                    L1_new=Ls1-Lm_new;
                    L2_new=Ls2-Lm_new*N21_new^2;
                    L3_new=Ls3-Lm_new*N31_new^2;
                end

                if(xWinding1Connection==1&&xWinding2Connection==1)||...
                    (xWinding1Connection==2&&xWinding2Connection==2)
                    VRated2_new=VRated1*N21_new;
                elseif xWinding1Connection==1&&xWinding2Connection==2
                    VRated2_new=VRated1*N21_new/sqrt(3);
                else
                    VRated2_new=VRated1*N21_new*sqrt(3);
                end

                if(xWinding1Connection==1&&xWinding3Connection==1)||...
                    (xWinding1Connection==2&&xWinding3Connection==2)
                    VRated3_new=VRated1*N31_new;
                elseif xWinding1Connection==1&&xWinding3Connection==2
                    VRated3_new=VRated1*N31_new/sqrt(3);
                else
                    VRated3_new=VRated1*N31_new*sqrt(3);
                end

                b_new=ee.internal.perunit.TransformerBase(SRated,FRated,VRated1,xWinding1Connection,VRated2_new,xWinding2Connection,VRated3_new,xWinding3Connection);

                L1_pu=L1_new/b_new.winding(1).L;
                L2_pu=L2_new/b_new.winding(2).L;
                L3_pu=L3_new/b_new.winding(3).L;
                Lm_pu=Lm_new/b_new.winding(1).L;

                obj.NewDerivedParam.pu_Xl1=L1_pu;
                obj.NewDerivedParam.pu_Xl2=L2_pu;
                obj.NewDerivedParam.pu_Xl3=L3_pu;
                obj.NewDerivedParam.pu_Xm=Lm_pu;
                obj.NewDerivedParam.VRated2=VRated2_new;
                obj.NewDerivedParam.VRated3=VRated3_new;

            end


            P0_pu=obj.OldParam.NoLoadPlossZero/SRated;
            I0_pu=obj.OldParam.NoLoadIexcZero/100;
            X120_pu=obj.OldParam.ShortCircuitReactanceZero(1);
            X130_pu=obj.OldParam.ShortCircuitReactanceZero(2);
            X230_pu=obj.OldParam.ShortCircuitReactanceZero(3);


            Q0_pu=sqrt(I0_pu^2-P0_pu^2);

            if strcmp(obj.OldDropdown.X12ZeroMeasuredWithW3Delta,'on')
                X120_pu_new=X130_pu+X230_pu-2*sqrt(X230_pu*(X130_pu-X120_pu));
            else
                X120_pu_new=X120_pu;
            end

            Xm012_pu=sqrt((1/Q0_pu)*((1/Q0_pu)-X120_pu_new));
            Xm013_pu=sqrt((1/Q0_pu)*((1/Q0_pu)-X130_pu));
            Xm023_pu=sqrt((1/Q0_pu)*((1/Q0_pu)-X230_pu));
            X0_pu=(Xm012_pu+Xm013_pu+Xm023_pu)/3;
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

            switch obj.OldDropdown.Winding3Connection
            case 'Y'
                obj.NewDropdown.Winding3Connection='1';
            case 'Yn'
                obj.NewDropdown.Winding3Connection='2';
            case 'Yg'
                obj.NewDropdown.Winding3Connection='3';
            case 'Delta (D1)'
                obj.NewDropdown.Winding3Connection='4';
            case 'Delta (D11)'
                obj.NewDropdown.Winding3Connection='5';
            end
        end
    end

end
