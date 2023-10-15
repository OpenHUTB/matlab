classdef Controller < handle





    properties
        Model
        App
    end

    methods

        function obj = Controller( Model, App )


            arguments
                Model( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.AppModel{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.model.AppModel;
                App( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.AppView{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.view.AppView;
            end
            obj.Model = Model;
            obj.App = App;
        end


        function execute( obj, src, evt )







            notify( obj.Model, 'RunningStage' );


            process( obj, src, evt );


            notify( obj.Model, 'CompletedStage' );
        end
    end

    methods ( Access = protected )

        function rtn = getOldValue( obj, EventData )






            arguments
                obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.controller.Controller;%#ok<INUSA>
                EventData = [  ];
            end

            if ~isempty( EventData )
                if isfield( EventData, 'OldValue' )
                    rtn = EventData.OldValue;
                else
                    rtn = 1;
                end
            else
                rtn = 1;
            end
        end

        function produce( obj, PlotType, src, evt )

            arguments
                obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.controller.Controller;
                PlotType{ mustBeTextScalar }
                src( 1, 1 )matlab.ui.internal.toolstrip.ToggleGalleryItem = [  ];
                evt( 1, 1 )matlab.ui.internal.toolstrip.base.ToolstripEventData = [  ];
            end


            document = [ PlotType, 'Document' ];


            if src.Value
                if ~getOldValue( obj, evt.EventData )

                    obj.App.( document ).Visible = true;
                end

                update( obj.App.( document ) );

                log( obj.Model.Logger, [ '% ', PlotType, ' Button Pressed.' ] );
            else
                if getOldValue( obj, evt.EventData )

                    obj.App.( document ).Visible = false;
                end
            end
        end
    end
end


