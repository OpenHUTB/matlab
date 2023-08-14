function v=validateLogDataHistory(~,v)




    isPositiveScalarInteger=@(number)(isnumeric(number)&&isscalar(number)...
    &&floor(number)==number&&number>0);

    if~isPositiveScalarInteger(v)
        pm_error('physmod:simscape:logging:sli:settings:InvalidLimitDataPoints',num2str(v));
    end

end
