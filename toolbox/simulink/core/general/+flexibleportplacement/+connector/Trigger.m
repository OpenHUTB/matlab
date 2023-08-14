classdef Trigger<flexibleportplacement.connector.ControlPort




    properties(SetAccess=private)
        DisplayName='Trigger'
    end

    methods
        function obj=Trigger(ph)
            obj=obj@flexibleportplacement.connector.ControlPort(ph);
        end
    end
end

