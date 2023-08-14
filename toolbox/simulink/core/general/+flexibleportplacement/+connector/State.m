classdef State<flexibleportplacement.connector.ControlPort




    properties(SetAccess=private)
        DisplayName='State'
    end

    methods
        function obj=State(ph)
            obj=obj@flexibleportplacement.connector.ControlPort(ph);
        end
    end
end

