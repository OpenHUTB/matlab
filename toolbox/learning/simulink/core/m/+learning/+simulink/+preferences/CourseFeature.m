





classdef CourseFeature
    properties(Constant)
        StartLearn='LearnTab'
        Entitlement='SimulinkCourseEntitlement'
    end

    methods(Static)
        function showCourses(settings)

            features=fieldnames(settings);
            for k=1:numel(features)


            end
        end

        function hasfeature=hasFeature(featureName)


            hasfeature=true;
        end
    end
end