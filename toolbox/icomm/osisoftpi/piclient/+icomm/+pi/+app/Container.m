classdef Container<matlab.mixin.SetGet&matlab.mixin.Heterogeneous






    properties(GetAccess=public,SetAccess=public,Dependent)
Parent
Position
Layout
    end

    properties(GetAccess=protected,Constant)
        TemporaryFigureTag="FigureToDeleteOnReparent"
    end

    properties(GetAccess=public,SetAccess=private)
UiContainer
    end

    methods

        function value=get.Parent(this)
            value=this.UiContainer.Parent;
        end

        function set.Parent(this,value)
            oldParent=this.UiContainer.Parent;
            this.UiContainer.Parent=value;
            if isa(oldParent,'matlab.ui.Figure')&&oldParent.Tag==this.TemporaryFigureTag
                delete(oldParent);
            end
        end

        function value=get.Position(this)
            value=this.UiContainer.Position;
        end

        function set.Position(this,value)
            this.UiContainer.Position=value;
        end

        function value=get.Layout(this)
            value=this.UiContainer.Layout;
        end

        function set.Layout(this,value)
            this.UiContainer.Layout=value;
        end

    end

    methods(Access=public)

        function this=Container(container,varargin)
            this.UiContainer=container;
            this.initialize();
            if~isempty(varargin)
                this.set(varargin{:});
            end
        end

    end

    methods(Access=protected)

        function initialize(~)
        end

    end

end