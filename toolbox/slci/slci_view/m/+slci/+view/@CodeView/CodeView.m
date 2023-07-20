


classdef CodeView<slci.view.Panel
    properties
cv
    end

    methods(Access=?slci.view.Studio)

        function obj=CodeView(st)
            obj@slci.view.Panel(st);





        end
    end

    methods
        function delete(obj)

        end


        turnOff(studio)
        show(obj)
        refresh(obj)
    end

    methods(Access=protected)

        init(obj)
    end
end