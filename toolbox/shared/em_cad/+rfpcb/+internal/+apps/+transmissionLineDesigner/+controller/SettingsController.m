classdef SettingsController < rfpcb.internal.apps.transmissionLineDesigner.controller.Controller





    methods

        function obj = SettingsController( Model, App )


            arguments
                Model( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.AppModel{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.model.AppModel;
                App( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.AppView{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.view.AppView;
            end
            obj@rfpcb.internal.apps.transmissionLineDesigner.controller.Controller( Model, App );

            log( obj.Model.Logger, '% SettingsController is created.' )

            registerListeners( obj );
        end


        function process( obj, src, evt )



            arguments
                obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.controller.SettingsController{ mustBeNonempty };
                src = [  ];%#ok<INUSA>
                evt = [  ];%#ok<INUSA>
            end
            window = obj.App.AppContainer.WindowBounds;
            centerX = window( 1 ) + window( 3 ) / 2;
            centerY = window( 2 ) + window( 4 ) / 2;
            center = [ centerX, centerY ];

            show( obj.App.SettingsView, 'Center', center );

            log( obj.Model.Logger, '% Charge Button Pressed.' );
        end
    end

    methods ( Access = private )

        function registerListeners( obj )
            obj.App.SettingsView.UnitsDropdown.ValueChangedFcn = @( src, evt )unitsChangedCallback( obj, src, evt );
            obj.App.SettingsView.SnapToGridCheckbox.ValueChangedFcn = @( src, evt )snapToGridCallback( obj, src, evt );
            obj.App.SettingsView.GridResolutionEditField.ValueChangedFcn = @( src, evt )gridResolutionCallback( obj, src, evt );
            obj.App.SettingsView.ResultsPerUnitLengthcheckbox.ValueChangedFcn = @( src, evt )resultsPerUnitLengthCallback( obj, src, evt );
            obj.App.SettingsView.Figure.CloseRequestFcn = @( src, evt )close( obj, src, evt );
            obj.App.SettingsView.CancelButton.ButtonPushedFcn = @( src, evt )close( obj, src, evt );
        end


        function unitsChangedCallback( obj, src, evt )


            arguments
                obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.controller.SettingsController;%#ok<INUSA>
                src( 1, 1 )matlab.ui.control.DropDown = [  ];%#ok<INUSA>
                evt = [  ];%#ok<INUSA>
            end

        end


        function snapToGridCallback( obj, src, evt )


            arguments
                obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.controller.SettingsController;%#ok<INUSA>
                src( 1, 1 )matlab.ui.control.CheckBox = [  ];%#ok<INUSA>
                evt = [  ];%#ok<INUSA>
            end

        end

        function gridResolutionCallback( obj, src, evt )




            arguments
                obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.controller.SettingsController;%#ok<INUSA>
                src( 1, 1 )matlab.ui.control.EditField = [  ];%#ok<INUSA>
                evt = [  ];%#ok<INUSA>
            end
        end

        function resultsPerUnitLengthCallback( obj, src, evt )




            arguments
                obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.controller.SettingsController;%#ok<INUSA>
                src( 1, 1 )matlab.ui.control.CheckBox = [  ];%#ok<INUSA>
                evt = [  ];%#ok<INUSA>
            end
        end

        function close( obj, src, evt )
            arguments
                obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.controller.SettingsController;
                src( 1, 1 ){ mustBeA( src, { 'matlab.ui.Figure', 'matlab.ui.control.Button' } ) } = [  ];%#ok<INUSA>
                evt( 1, 1 ){ mustBeA( evt, { 'matlab.ui.eventdata.WindowCloseRequestData', 'matlab.ui.eventdata.ButtonPushedData' } ) } = [  ];
            end
            if any( strcmpi( evt.EventName, { 'close', 'ButtonPushed' } ) )
                obj.App.SettingsView.Figure.Visible = 'off';
            end
        end
    end
end


