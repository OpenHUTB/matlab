classdef InterfaceComponent < simscape.statistics.gui.util.internal.GuiComponent
    properties ( Constant )
        Layout = lLayout(  );
        Tag = lPanel(  );
    end
    properties ( Access = private )
        InterfacePanel = [  ]
        Data
    end
    methods
        function obj = InterfaceComponent( data )
            obj.Data = data;
        end
        function render( obj, figuresMap )
            if isempty( obj.InterfacePanel )
                fig = figuresMap.( lPanel(  ) );
                parent = findobj( fig, 'Tag', obj.Tag );
                if isempty( parent )
                    parent = uigridlayout( fig, 'ColumnWidth', { '1x' }, 'RowHeight', { '1x' }, 'Tag', obj.Tag );
                end
                obj.InterfacePanel = simscape.statistics.gui.internal.InterfacePanel(  ...
                    obj.Data, parent );
            end
        end
        function out = label( ~, tag )
            out = "";
            if strcmp( tag, lPanel(  ) )
                out = "1-D/3-D Interface";
            end
        end
        function out = description( obj )
            arguments
                obj( 1, 1 )
            end
            out = obj.Data.Properties.Description;
        end
    end
end

function tag = lPanel(  )
tag = "Interfaces";
end

function layout = lLayout(  )
layout = simscape.statistics.gui.util.internal.Layout( lPanel(  ) );
end

