function subModelConfigs=trimFieldsOf1DArrayofSubModelConfigs(subModelConfigs)




    len=length(subModelConfigs);
    for i=1:len
        val=subModelConfigs(i);
        val.ModelName=strtrim(val.ModelName);
        val.ConfigurationName=strtrim(val.ConfigurationName);
        subModelConfigs(i)=val;
    end
end
