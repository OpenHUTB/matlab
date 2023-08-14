function v=validateLogDecimation(~,v)




    isPositiveScalarInteger=@(number)(isnumeric(number)&&isscalar(number)...
    &&floor(number)==number&&number>0);

    if~isPositiveScalarInteger(v)
        pm_error('physmod:simscape:logging:sli:settings:InvalidDecimation',num2str(v));
    end

end
