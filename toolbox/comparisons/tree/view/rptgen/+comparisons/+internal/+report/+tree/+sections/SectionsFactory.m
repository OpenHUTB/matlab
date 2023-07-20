classdef SectionsFactory<handle





    methods(Abstract,Access=public)




        sections=create(obj,differences,reportFormat)


        applies=appliesToDiff(obj,mcosView,rootEntry)


        priority=getPriority(obj)
    end

end
