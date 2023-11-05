classdef(Abstract)DiffNoGUIProvider<handle&matlab.mixin.Heterogeneous

    methods(Abstract)
        canHandle(first,second,showchars);

        handle(first,second,showchars);

        getPriority(first,second,showchars);

        getType();

        getDisplayType();
    end

end
