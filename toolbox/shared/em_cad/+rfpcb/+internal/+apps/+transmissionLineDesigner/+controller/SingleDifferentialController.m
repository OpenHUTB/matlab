classdef SingleDifferentialController < rfpcb.internal.apps.transmissionLineDesigner.controller.Controller

    methods

        function obj = SingleDifferentialController( Model, App )





            arguments
                Model( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.AppModel{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.model.AppModel;
                App( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.AppView{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.view.AppView;
            end
            obj@rfpcb.internal.apps.transmissionLineDesigner.controller.Controller( Model, App );

            log( obj.Model.Logger, '% SingleDifferentialController is created.' )
        end


        function process( obj, src, evt )


            arguments
                obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.controller.SingleDifferentialController{ mustBeNonempty };
                src = [  ];%#ok<INUSA>
                evt = [  ];%#ok<INUSA>
            end


            log( obj.Model.Logger, '% Single differential radio button pressed.' );
        end
    end
end


