function courses=getUserCourseList()








    onramps=getOnrampCourses;

    fundamentalunits=struct('units',learning.simulink.preferences.slmodules.ModuleMap,'code','slbe');
    staticCourses=struct('fundamentalunits',fundamentalunits,'onramps',onramps,'release',learning.simulink.internal.PortalUrlBuilder.release);

    isEntitled=learning.simulink.preferences.CourseFeature.hasFeature(learning.simulink.preferences.CourseFeature.Entitlement);

    if~isEntitled
        staticCourses.mockEntitled=true;
    end

    courses=jsondecode(jsonencode(staticCourses));


    function onramps=getOnrampCourses
        onramps=struct();
        for k=keys(learning.simulink.preferences.slacademyprefs.CourseMap)

            if learning.simulink.preferences.slacademyprefs.CourseMap(k{1}).category==learning.simulink.preferences.Category.FREE
                onramps=setfield(onramps,k{1},learning.simulink.preferences.slacademyprefs.CourseMap(k{1}));
            end
        end
    end
end
