classdef WindowFactory<handle&matlab.mixin.Heterogeneous

    methods(Abstract)

        bool=canDisplay(obj,contentId,location)

        window=create(obj,contentId,location)

    end

end
