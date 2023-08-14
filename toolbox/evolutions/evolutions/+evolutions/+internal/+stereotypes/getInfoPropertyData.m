function[jsonData,structData]=getInfoPropertyData(info)




    jsonData=fileread(info.PropertyDataFile);
    structData=jsondecode(jsonData);
end
