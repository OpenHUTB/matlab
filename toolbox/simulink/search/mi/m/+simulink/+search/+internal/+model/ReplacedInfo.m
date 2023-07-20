

classdef ReplacedInfo<handle

    methods(Access=public)
        function obj=ReplacedInfo(propertyId,propertydata)
            obj.propertyId=propertyId;
            obj.propertydata=propertydata;
        end
    end

    properties(Access=public)
        propertyId=[];
        propertydata=[];
    end
end
