classdef ModuleInfo


    properties
CourseInfo
ModuleName
Chapter
Lesson
Section
modules
hours
DisplayOrder
    end

    methods
        function obj=ModuleInfo(courseInfo,moduleName,chapter,lesson,section,modules,hours,displayOrder)
            obj.CourseInfo=courseInfo;
            obj.ModuleName=moduleName;
            obj.Chapter=chapter;
            obj.Lesson=lesson;
            obj.Section=section;
            obj.modules=modules;
            obj.hours=hours;
            obj.DisplayOrder=displayOrder;
        end
    end
end

