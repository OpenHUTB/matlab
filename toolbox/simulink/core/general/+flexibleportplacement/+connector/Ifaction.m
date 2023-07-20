classdef Ifaction<flexibleportplacement.connector.ControlPort




    properties(SetAccess=private)
        DisplayName='Ifaction'
    end

    methods
        function obj=Ifaction(ph)
            obj=obj@flexibleportplacement.connector.ControlPort(ph);
        end
    end
end

