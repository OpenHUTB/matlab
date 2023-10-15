classdef ChargeView < rfpcb.internal.apps.transmissionLineDesigner.view.Document

    properties
        Charge
    end

    methods

        function obj = ChargeView( Charge )

            arguments
                Charge( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Charge{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.model.Charge;
            end
            obj.Charge = Charge;
            obj.DocumentGroupTag = 'analysisGroup';

            obj.Tag = 'chargeDocument';
            obj.Title = getString( message( "rfpcb:transmissionlinedesigner:ChargeDocument" ) );
            obj.Tile = 2;
            obj.Visible = false;

            debug( obj.Charge.Logger, 'ChargeDocument = matlab.ui.internal.FigureDocument("Tag", "chargeDocument", "DocumentGroupTag", "analysisGroup");' );
        end


        function produce( obj )

            arguments
                obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.ChargeView
            end

            if obj.Visible

                compute( obj.Charge, 'SuppressOutput', false );
            end
        end
    end
end


