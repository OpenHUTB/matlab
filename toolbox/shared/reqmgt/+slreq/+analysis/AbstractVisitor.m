classdef(Abstract)AbstractVisitor<handle


    properties(Abstract)
        name;
    end

    methods(Abstract)


        visitRequirementSet(this,requirementSet);
        visitRequirement(this,requirement);
    end

    methods
        visitLinkSet(this,linkSet);
        visitLink(this,link);
    end
end