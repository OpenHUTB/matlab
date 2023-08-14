classdef AbstractItem









    properties
Name
Source
    end
    methods

        function obj=AbstractItem()
            obj.Name='';
            obj.Source=[];
        end

    end
    methods
        obj=setNameFromSource(obj);
    end
end


