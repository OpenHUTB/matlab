classdef StudentAssessment<handle



    properties(Abstract,Constant)
type
    end

    properties
        hasPlot=false;
    end

    methods(Abstract)



        assess(userModelName)



        generateRequirementString()
    end
end

