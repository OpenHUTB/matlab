classdef(Abstract)GuiComponent<handle&matlab.mixin.Heterogeneous












    properties(Constant,Abstract)
        Layout(1,1)simscape.statistics.gui.util.internal.Layout;
    end



    properties(Dependent)
Tags
    end
    methods(Abstract)



        render(obj,containerMap);


        out=label(obj,tag);


        out=description(obj);
    end

    methods

        function out=get.Tags(obj)
            out=obj.Layout.Tags;
        end
    end
end