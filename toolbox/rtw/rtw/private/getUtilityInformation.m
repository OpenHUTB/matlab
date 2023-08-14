function information=getUtilityInformation(scmFilePath,utilityName,property,modelName)



    information=[];
    persistent utilityMap;
    persistent utilFileTimeStamp;

    if nargin<1
        utilityMap=[];
        utilFileTimeStamp=[];
        return;
    end

    flag=3;

    if nargin<2
        flag=0;
        utilityName=[];
        property=[];
        modelName=[];
    elseif nargin<3
        flag=1;
        property=[];
        modelName=[];
    elseif nargin<4
        flag=2;
        modelName=[];
    end
    fileInfo=dir(scmFilePath);

    if(isempty(utilFileTimeStamp)||(~isempty(fileInfo)&&fileInfo.datenum>utilFileTimeStamp))
        utilityMap=containers.Map;
        scm=SharedCodeManager.SharedCodeManagerInterface(scmFilePath);
        data=scm.retrieveAllData('SCM_UTILITIES');
        for i=1:length(data)
            utilityMap(data{i}.Name)=data{i};
        end
        clear scm;
        if~isempty(fileInfo)
            utilFileTimeStamp=fileInfo.datenum;
        end
    end

    switch(flag)
    case 0
        information=values(utilityMap);
    case 1
        if isKey(utilityMap,utilityName)
            information=utilityMap(utilityName);
        end
    case 2
        if isKey(utilityMap,utilityName)
            temp=utilityMap(utilityName);
            information=temp.(property);
        end
    case 3
        if isKey(utilityMap,utilityName)
            temp=utilityMap(utilityName);

            information=temp.getTraceabilityForModel(modelName);
        end
    end




