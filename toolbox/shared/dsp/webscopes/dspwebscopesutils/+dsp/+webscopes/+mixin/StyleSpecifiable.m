classdef StyleSpecifiable<handle






    properties(Hidden)

        Style;
    end



    methods(Access=protected)

        function addStyleSpecification(this)
            this.Style=getStyleSpecification(this);
        end
    end



    methods(Abstract,Access=protected)

        spec=getStyleSpecification(this)
    end
end
