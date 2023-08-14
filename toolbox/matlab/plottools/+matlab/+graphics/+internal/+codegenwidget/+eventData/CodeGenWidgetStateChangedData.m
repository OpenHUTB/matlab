classdef CodeGenWidgetStateChangedData<matlab.ui.eventdata.internal.AbstractEventData





    properties(SetAccess='private')
        Data;
    end

    methods
        function obj=CodeGenWidgetStateChangedData(data)




            obj=obj@matlab.ui.eventdata.internal.AbstractEventData();

            obj.Data=data;
        end
    end
end