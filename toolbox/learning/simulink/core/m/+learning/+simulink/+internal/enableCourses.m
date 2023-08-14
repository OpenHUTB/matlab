function enableCourses(varargin)












    start=1;
    entitlementCheck=0;
    Entitlement=learning.simulink.preferences.CourseFeature.Entitlement;

    if~isempty(varargin)

        if islogical(varargin{1})
            start=varargin{1};
        end


        if isstruct(varargin{1})
            if isfield(varargin{1},Entitlement)
                entitlementCheck=getfield(varargin{1},Entitlement);
            end
        end
    end

    setting=struct(learning.simulink.preferences.CourseFeature.StartLearn,start,Entitlement,entitlementCheck);
    learning.simulink.preferences.CourseFeature.showCourses(setting);
end