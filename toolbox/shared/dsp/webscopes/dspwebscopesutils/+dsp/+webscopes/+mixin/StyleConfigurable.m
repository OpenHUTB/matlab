classdef StyleConfigurable<handle





    properties(Hidden)

        Style;
    end



    methods(Access=protected)

        function addStyleConfiguration(this)
            this.Style=getStyleConfiguration(this);
        end
    end



    methods(Abstract,Access=protected)

        style=getStyleConfiguration(this)
    end
end
