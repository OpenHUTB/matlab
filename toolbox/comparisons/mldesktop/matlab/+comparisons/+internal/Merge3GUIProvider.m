classdef(Abstract)Merge3GUIProvider<handle&matlab.mixin.Heterogeneous

    methods(Abstract)
        canHandle(theirs,base,mine,options);

        handle(theirs,base,mine,options);

        getPriority(theirs,base,mine,options);

        getType();

        getDisplayType();
    end

end
