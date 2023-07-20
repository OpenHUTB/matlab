classdef RegisteredTaskTemplate<livetask.internal.LiveTaskBaseInterface












    properties(Abstract)
        MainGrid matlab.ui.container.GridLayout
    end


    methods

        update(app,data);
    end

end
