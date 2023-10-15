classdef TextComponent < simscape.statistics.gui.util.internal.GuiComponent





    properties ( Constant )
        Layout = lLayout(  );
    end
    methods
        function obj = TextComponent( args )
            arguments
                args.Text( 1, 1 )string{ mustBeNonmissing } = ""
                args.Label( 1, 1 )string = missing
            end
            obj.Text = args.Text;
            obj.Label = args.Label;
        end
        function render( obj, figureMap )
            if isempty( obj.TextPanel ) || ~isvalid( obj.TextPanel )
                fig = figureMap.( "Description" );
                obj.TextPanel =  ...
                    uitextarea(  ...
                    uigridlayout( fig, 'ColumnWidth', { '1x' }, 'RowHeight', { '1x' } ),  ...
                    'Value', obj.Text );
            else
                set( obj.TextPanel, 'Value', obj.Text );
            end

        end
        function out = label( obj, ~ )
            arguments
                obj( 1, 1 )
                ~
            end
            out = obj.Label;
        end
        function out = description( obj )
            arguments
                obj( 1, 1 )
            end
            out = obj.Text;
        end
    end


    properties
        Text( 1, 1 )string{ mustBeNonmissing }
        Label( 1, 1 )string
    end
    properties ( Access = private )
        TextPanel = [  ]
    end
end

function layout = lLayout(  )
layout = simscape.statistics.gui.util.internal.Layout( "Description" );
end

