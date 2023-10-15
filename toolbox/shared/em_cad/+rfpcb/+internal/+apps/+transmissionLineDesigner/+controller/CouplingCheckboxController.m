classdef CouplingCheckboxController < rfpcb.internal.apps.transmissionLineDesigner.controller.Controller

    methods

        function obj = CouplingCheckboxController( Model, App )
            arguments
                Model( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.AppModel{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.model.AppModel;
                App( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.AppView{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.view.AppView;
            end
            obj@rfpcb.internal.apps.transmissionLineDesigner.controller.Controller( Model, App );

            log( obj.Model.Logger, '% CouplingController is created.' )
        end


        function process( obj, src, evt )


            arguments
                obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.controller.CouplingCheckboxController{ mustBeNonempty };
                src = [  ];%#ok<INUSA>
                evt = [  ];%#ok<INUSA>
            end

            log( obj.Model.Logger, '% Coupling configuration changed.' );
        end
    end
end

