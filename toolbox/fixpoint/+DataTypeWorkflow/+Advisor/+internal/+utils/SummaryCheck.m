classdef SummaryCheck




    properties(SetAccess=private,GetAccess=public)
Name
Status
    end

    methods
        function obj=SummaryCheck(name,status)
            obj.Name=name;
            obj.Status=status;
        end
    end
end

