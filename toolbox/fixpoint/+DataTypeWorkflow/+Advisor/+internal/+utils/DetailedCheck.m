classdef DetailedCheck




    properties(SetAccess=private,GetAccess=public)
Name
Summary
Headers
Info
    end

    methods
        function obj=DetailedCheck(name,status,headers,info)
            obj.Name=name;
            obj.Summary=status;
            obj.Headers=headers;
            obj.Info=info;
        end
    end
end

