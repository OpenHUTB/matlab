classdef TransmissionLineController < rfpcb.internal.apps.transmissionLineDesigner.controller.Controller

    methods

        function obj = TransmissionLineController( Model, App )

            arguments
                Model( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.AppModel{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.model.AppModel;
                App( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.AppView{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.view.AppView;
            end
            obj@rfpcb.internal.apps.transmissionLineDesigner.controller.Controller( Model, App );

            log( obj.Model.Logger, '% TransmissionLineController is created.' )
        end


        function process( obj, src, evt )


            arguments
                obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.controller.TransmissionLineController{ mustBeNonempty };
                src( 1, 1 )matlab.ui.internal.toolstrip.ToggleGalleryItem = [  ];
                evt( 1, 1 )matlab.ui.internal.toolstrip.base.ToolstripEventData = [  ];%#ok<INUSA>
            end
            if strcmpi( src.Tag, 'microstripBuried' )
                tLine = microstripLine;
                tLine.Substrate = dielectric(  ...
                    'Name', { 'Teflon', 'Teflon' },  ...
                    'EpsilonR', [ 2.1, 2.1 ],  ...
                    'LossTangent', [ 0, 0 ],  ...
                    'Thickness', [ tLine.Height, tLine.Height ] );
            else
                tLine = eval( src.Tag );
            end

            obj.Model.TransmissionLine = tLine;

            log( obj.Model.Logger, [ src.Tag, ' Selected.' ] );
        end
    end
end

