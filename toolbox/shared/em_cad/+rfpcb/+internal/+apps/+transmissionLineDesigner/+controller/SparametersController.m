classdef SparametersController < rfpcb.internal.apps.transmissionLineDesigner.controller.Controller

    methods

        function obj = SparametersController( Model, App )




            arguments
                Model( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.AppModel{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.model.AppModel;
                App( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.AppView{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.view.AppView;
            end
            obj@rfpcb.internal.apps.transmissionLineDesigner.controller.Controller( Model, App );

            log( obj.Model.Logger, '% SparametersController is created.' )
        end


        function process( obj, src, evt )

            arguments
                obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.controller.SparametersController{ mustBeNonempty };
                src( 1, 1 )matlab.ui.internal.toolstrip.ToggleGalleryItem = [  ];
                evt( 1, 1 )matlab.ui.internal.toolstrip.base.ToolstripEventData = [  ];
            end


            produce( obj, 'Sparameters', src, evt );

        end
    end
end



