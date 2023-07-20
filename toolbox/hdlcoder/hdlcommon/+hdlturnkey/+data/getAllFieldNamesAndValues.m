


function dataValueMap=getAllFieldNamesAndValues(dataValue,dataName,dataValueMap)














































    if nargin<2
        dataName='';
    end
    if nargin<3
        dataValueMap=containers.Map();
    end
    if isstruct(dataValue)
        allFieldNames=fieldnames(dataValue);
        for idx=1:length(allFieldNames)
            currFieldName=[dataName,'.',allFieldNames{idx}];
            currFielddataValue=dataValue.(allFieldNames{idx});
            dataValueMap=hdlturnkey.data.getAllFieldNamesAndValues(...
            currFielddataValue,currFieldName,dataValueMap);
        end
    else
        dataValueMap(dataName)=dataValue;
    end

end