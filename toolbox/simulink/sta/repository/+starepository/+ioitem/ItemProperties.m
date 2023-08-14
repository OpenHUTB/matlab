classdef ItemProperties<handle









    properties
Name
    end
    methods
        function obj=ItemProperties(Name)





            obj.Name=Name;
        end



















    end

    methods(Abstract)







        getPropertyNames(obj);
    end


end


