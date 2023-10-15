classdef PropertiesController < rfpcb.internal.apps.transmissionLineDesigner.controller.Controller

    methods

        function obj = PropertiesController( Model, App )


            arguments
                Model( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.AppModel{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.model.AppModel;
                App( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.AppView{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.view.AppView;
            end

            obj@rfpcb.internal.apps.transmissionLineDesigner.controller.Controller( Model, App );

            log( obj.Model.Logger, '% PropertiesController is created.' )
        end


        function process( obj, ~, ~ )
            update( obj );
        end


        function update( obj )
            arguments
                obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.controller.PropertiesController{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.controller.PropertiesController;
            end
            if ~obj.App.AppContainer.Visible
                addComponent2Container( obj.App, 'Component', 'PropertyPanel' );
                obj.App.AppContainer.Visible = true;
            end
            if isempty( obj.Model.Properties.TransmissionLine )

            else


            end
        end
    end
end


