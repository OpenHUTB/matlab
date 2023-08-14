function res=getModelAdvisorStandardIssues(app,taskIDs)













    systemSIDMap=containers.Map();

    for n=1:length(taskIDs)







        [status,systemSIDs]=app.getStatusForTask(taskIDs{n});


        if isempty(status)
            continue;
        end


        lgx=status>1;
        systemSIDs=systemSIDs(lgx);
        clear status;


        for i=1:length(systemSIDs)

            checkID=app.getCheckIDForInstance(taskIDs{n});
            systemSID=systemSIDs{i};


            if ModelAdvisor.internal.isConfigSetCheck(checkID)
                issues={{systemSID}};
            else
                [data,systemSIDs]=app.getOffendingObjects(taskIDs{n});
                issues=data(i);
            end

            checkIssues=struct(...
            'CheckID',checkID,...
            'CheckInstanceID',taskIDs{n},...
            'Issues',issues);


            if systemSIDMap.isKey(systemSID)
                systemSIDMap(systemSID)=[systemSIDMap(systemSID),checkIssues];
            else
                systemSIDMap(systemSID)=checkIssues;
            end
        end

    end

    systemSIDsFromMap=systemSIDMap.keys;

    res=...
    repmat(struct('SystemSID',{},'ReportedSIDs',{}),1,systemSIDMap.Count);

    for n=length(systemSIDsFromMap):-1:1
        res(n).SystemSID=systemSIDsFromMap{n};
        res(n).ReportedSIDs=systemSIDMap(systemSIDsFromMap{n});
    end

end