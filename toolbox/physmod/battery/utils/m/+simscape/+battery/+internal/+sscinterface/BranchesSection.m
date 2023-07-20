classdef(Sealed,Hidden)BranchesSection<simscape.battery.internal.sscinterface.Section




    properties(Constant)
        Type="BranchesSection";
    end

    properties(Constant,Access=protected)
        SectionIdentifier="branches";
    end

    methods
        function obj=BranchesSection()

        end

        function obj=addBranch(obj,componentVariable,domainVariable1,domainVariable2)



            obj.SectionContent(end+1)=simscape.battery.internal.sscinterface.Branch(componentVariable,domainVariable1,domainVariable2);
        end
    end
end
