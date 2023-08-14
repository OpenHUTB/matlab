classdef CustomDependency



    properties
getStatusFcn
    end

    methods
        function obj=CustomDependency(fcn)
            if isempty(strfind(fcn,'.'))


                fcn=['configset.internal.custom.',fcn];
            end
            obj.getStatusFcn=str2func(fcn);
        end

        status=getStatus(obj,cs,name)
    end
end
