classdef CurrentView < rfpcb.internal.apps.transmissionLineDesigner.view.Document

    properties
        Current
    end

    methods

        function obj = CurrentView( Current )

            arguments
                Current( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Current{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.model.Current;
            end
            obj.Current = Current;
            obj.DocumentGroupTag = 'analysisGroup';

            obj.Tag = 'currentDocument';
            obj.Title = getString( message( "rfpcb:transmissionlinedesigner:CurrentDocument" ) );
            obj.Tile = 2;
            obj.Visible = false;

            debug( obj.Current.Logger, 'CurrentDocument = matlab.ui.internal.FigureDocument("Tag", "currentDocument", "DocumentGroupTag", "analysisGroup");' );
        end


        function produce( obj )

            arguments
                obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.CurrentView
            end

            if obj.Visible

                compute( obj.Current, 'SuppressOutput', false );
            end
        end
    end
end


