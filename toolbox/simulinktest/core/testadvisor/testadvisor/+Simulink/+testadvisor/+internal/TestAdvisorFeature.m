function value = TestAdvisorFeature(flag)
    persistent feature
    if isempty(feature)
        feature = 0;
    end
    if exist('flag', 'var')
       feature = flag;
    end
    value = feature;
end