classdef(Abstract)DiffGUIProvider<handle&matlab.mixin.Heterogeneous

    methods(Abstract)

        canHandle(first,second,options);

        handle(first,second,options);

        getPriority(first,second,options);

        getType();

        getDisplayType();
    end

end
