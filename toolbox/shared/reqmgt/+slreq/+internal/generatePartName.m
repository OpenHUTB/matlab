function part=generatePartName(loadSaveOptions)









    partName='slrequirements/';
    if strcmp(loadSaveOptions.getPartNamePrefix,'/simulink/')

        part=['/',partName];
    else

        part=[loadSaveOptions.getPartNamePrefix,partName];
    end
end