classdef ContentWindowFactory<handle&matlab.mixin.Heterogeneous

    methods(Abstract)

        bool=canDisplay(obj,contentId)

        window=create(obj,contentId)

    end

end
