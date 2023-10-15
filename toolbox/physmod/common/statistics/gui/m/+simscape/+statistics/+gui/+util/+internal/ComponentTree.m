classdef ComponentTree

    properties
        Component( 1, 1 )simscape.statistics.gui.util.internal.GuiComponent =  ...
            simscape.statistics.gui.util.internal.TextComponent
    end



    properties
        ID( 1, 1 )string{ mustBeValidVariableName } = "x"
        Children( 1, : )simscape.statistics.gui.util.internal.ComponentTree
        Label( 1, 1 )string = missing
    end

    methods

        function obj = ComponentTree( component, id, argsin )
            arguments
                component( 1, 1 )simscape.statistics.gui.util.internal.GuiComponent
                id( 1, 1 )string{ mustBeValidVariableName }
                argsin.Children( 1, : )simscape.statistics.gui.util.internal.ComponentTree
                argsin.Label( 1, 1 )string = missing
            end
            obj.Component = component;
            obj.ID = id;
            if isfield( argsin, 'Children' )
                obj.Children = argsin.Children;
            end
            obj.Label = argsin.Label;
        end
    end
end

