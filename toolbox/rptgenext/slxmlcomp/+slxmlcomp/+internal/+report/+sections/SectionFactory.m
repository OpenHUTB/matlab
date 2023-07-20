


classdef SectionFactory<handle

    methods(Abstract,Access=public)


        section=create(diffsGraphModel,sectionRootDiff,rptFormat,tempDir,comparisonSources);



        applies=appliesToDiff(obj,rootDiff);



        priority=getPriority(obj);

    end

end