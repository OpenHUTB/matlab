function out=isMetricsDashboardRunExtensiveChecks(varargin)
    mp=ModelAdvisor.Preferences;
    if nargin>0
        mp.MetricsDashboardRunExtensiveChecks=logical(varargin{1});
    end
    out=mp.MetricsDashboardRunExtensiveChecks;
end