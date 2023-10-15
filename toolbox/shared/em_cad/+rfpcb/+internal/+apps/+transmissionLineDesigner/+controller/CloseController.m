classdef CloseController < rfpcb.internal.apps.transmissionLineDesigner.controller.Controller

    methods

        function obj = CloseController( Model, App )




            arguments
                Model( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.AppModel{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.model.AppModel;
                App( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.AppView{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.view.AppView;
            end
            obj@rfpcb.internal.apps.transmissionLineDesigner.controller.Controller( Model, App );

            log( obj.Model.Logger, '% CloseController is created.' )

            obj.App.AppContainer.CanCloseFcn = @obj.execute;
        end


        function rtn = execute( obj, src, evt )


            arguments
                obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.controller.CloseController{ mustBeNonempty };
                src = [  ];%#ok<INUSA>
                evt = [  ];%#ok<INUSA>
            end

            delete( obj.App.SettingsView );
            sync( obj.App );
            rtn = true;
        end
    end
end

