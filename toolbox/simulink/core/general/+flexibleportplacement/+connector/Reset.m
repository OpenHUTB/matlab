classdef Reset<flexibleportplacement.connector.ControlPort




    properties(SetAccess=private)
        DisplayName='Reset'
    end

    methods
        function obj=Reset(ph)
            obj=obj@flexibleportplacement.connector.ControlPort(ph);
        end
    end
end

