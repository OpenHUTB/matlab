classdef ComparisonLayout<handle




    properties(Abstract,GetAccess=public,SetAccess=private)
ContentIds
    end


    methods(Access=public,Abstract)

        addWindow(obj,window,contentId)

        getWindow(obj,contentId)

        layout(obj)

    end

end
