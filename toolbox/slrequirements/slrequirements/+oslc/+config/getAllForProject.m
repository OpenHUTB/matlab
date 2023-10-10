function result=getAllForProject(projName)

    result.knownStreams=cell(0,4);
    result.knownBaselines=cell(0,4);
    result.knownChangesets=cell(0,4);
    currentName=oslc.Project.currentProject();

    if nargin==0||isempty(projName)

        if isempty(currentName)
            error(message('Slvnv:oslc:ProjectNotSpecified'));
        else
            projName=currentName;
        end
    else

        oslc.Project.currentProject(projName);
    end



    projectObj=oslc.Project.get(projName);

    if projectObj.isTesting
        return;
    end

    [streamsData,baselinesData,changesetsData]=projectObj.getAllConfigurations();

    if~isempty(streamsData)
        result.knownStreams=parseIDs(streamsData);
    end

    if~isempty(baselinesData)
        result.knownBaselines=parseIDs(baselinesData);
    end

    if~isempty(changesetsData)
        result.knownChangesets=parseIDs(changesetsData);
    end

end


function data=parseIDs(data)
    for i=1:size(data,1)
        tokens=regexp(data{i,1},'(\w+)/([-\w]+)$','tokens');
        if~isempty(tokens)
            data(i,3:4)=tokens{1};
        else
            data(i,3:4)={'???','???'};
        end
    end
end

