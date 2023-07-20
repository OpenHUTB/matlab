




function displayList=createSSRefInstanceDisplayList(blockHandle)

    displayList={};
    activeInstanceNames=slInternal('getActiveSRInstanceNames',blockHandle);
    if isempty(activeInstanceNames)
        return
    end

    instanceCount=length(activeInstanceNames);
    sortedActiveInstances=sort(activeInstanceNames(2:end));
    sortedActiveInstances=[activeInstanceNames{1};sortedActiveInstances];

    for ii=1:instanceCount
        instanceName=sortedActiveInstances{ii};


        if((contains(instanceName,'/')&&~bdIsLoaded(strtok(instanceName,'/')))||strcmp(instanceName,getfullname(blockHandle))||contains(getfullname(blockHandle),strcat(instanceName,'/')))
            continue;
        end
        displayList{end+1}=instanceName;%#ok<AGROW>
    end
end
