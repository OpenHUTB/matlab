function exclusionObjs=ExclusionManager(action,system,argin)




    persistent ExclusionData;

    if isempty(ExclusionData)
        ExclusionData=containers.Map;
    end

    switch action
    case 'add'

        if iscell(argin)
            ExclusionObj=[];
            for i=1:length(argin)
                ExclusionObj(end+1)=argin{i};
            end
        else
            ExclusionObj=argin;
        end

        for i=1:length(ExclusionObj)
            if isKey(ExclusionData,system)
                temp=ExclusionData(system);
                temp(end+1)=ExclusionObj(i);
                ExclusionData(system)=temp;
            else
                ExclusionData(system)=ExclusionObj(i);
            end
        end

    case 'get'
        exclusionObjs=[];
        keys=ExclusionData.keys;
        for i=1:length(keys)
            if~isempty(regexp(system,keys{i}))
                exclusionObjs=[exclusionObjs,ExclusionData(keys{i})];
            end
        end

    case 'clear'

        if strcmp(system,'*')
            ExclusionData=[];
        else
            ExclusionData.remove(system);
        end

    end