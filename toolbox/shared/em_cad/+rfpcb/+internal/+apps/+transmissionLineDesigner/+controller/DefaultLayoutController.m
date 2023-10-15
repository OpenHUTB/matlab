classdef DefaultLayoutController < rfpcb.internal.apps.transmissionLineDesigner.controller.Controller

    methods

        function obj = DefaultLayoutController( Model, App )


            arguments
                Model( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.AppModel{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.model.AppModel;
                App( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.AppView{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.view.AppView;
            end
            obj@rfpcb.internal.apps.transmissionLineDesigner.controller.Controller( Model, App );

            log( obj.Model.Logger, '% DefaultLayoutController is created.' )
        end


        function process( obj, src, evt )


            arguments
                obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.controller.DefaultLayoutController{ mustBeNonempty };
                src( 1, 1 )matlab.ui.internal.toolstrip.Button = [  ];%#ok<INUSA>
                evt( 1, 1 )event.EventData = [  ];%#ok<INUSA>
            end


            updateLayout( obj.App );


            log( obj.Model.Logger, '% Default layout Button Pressed.' );

        end
    end
end


