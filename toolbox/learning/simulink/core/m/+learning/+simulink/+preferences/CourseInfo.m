classdef CourseInfo




    properties
CourseName
        ProductNames={};
MessageCatalog
modules
hours
        purchaseUrl=''
category
    end

    methods
        function obj=CourseInfo(courseName,productNames,category,messageCatalog,modules,hours,purchaseUrl)
            obj.CourseName=courseName;
            obj.ProductNames=productNames;
            obj.category=category;
            obj.MessageCatalog=messageCatalog;
            obj.modules=modules;
            obj.hours=hours;
            if~isempty(purchaseUrl)
                obj.purchaseUrl=purchaseUrl;
            end
        end
    end
end
