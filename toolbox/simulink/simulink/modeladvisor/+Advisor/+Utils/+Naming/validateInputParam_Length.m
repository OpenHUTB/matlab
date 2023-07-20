function[minLength,maxLength]=validateInputParam_Length(inputParams,checkGroup)







    minLength=str2double(inputParams{4}.Value);
    maxLength=str2double(inputParams{5}.Value);


    if~isempty(minLength)&&~isnan(minLength)&&isnumeric(minLength)
        minLength=minLength(1);
    else
        minLength=str2double(Advisor.Utils.Naming.getNameLength(checkGroup));
    end

    if~isempty(maxLength)&&~isnan(maxLength)&&isnumeric(maxLength)
        maxLength=maxLength(1);
    else
        [~,maxLength]=Advisor.Utils.Naming.getNameLength(checkGroup);
        maxLength=str2double(maxLength);
    end
end

