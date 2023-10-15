classdef Document < matlab.ui.internal.FigureDocument

    methods

        function obj = Document(  )


        end


        function update( obj )



            currentFigure( obj );


            produce( obj );


            currentFigure( obj, false );
        end

        function rtn = getCurrentState( obj )

            rtn = obj.Visible;
        end

    end

    methods ( Access = private )

        function currentFigure( obj, OnOff )




            arguments
                obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.Document{ mustBeNonempty }
                OnOff = true;
            end


            obj.Figure.Internal = ~OnOff;


            if OnOff
                obj.Figure.Pointer = 'watch';
                obj.Figure.HandleVisibility = 'on';
            else
                obj.Figure.Pointer = 'arrow';
                obj.Figure.HandleVisibility = 'off';
            end


            set( groot, 'CurrentFigure', obj.Figure );
        end
    end
end


