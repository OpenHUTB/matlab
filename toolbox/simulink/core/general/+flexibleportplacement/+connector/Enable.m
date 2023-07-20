classdef Enable<flexibleportplacement.connector.ControlPort




    properties(SetAccess=private)
        DisplayName='Enable'
    end

    methods
        function obj=Enable(ph)
            obj=obj@flexibleportplacement.connector.ControlPort(ph);
        end
    end
end

