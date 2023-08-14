function compliance=getModelAdvisorStandardComplianceData(app,taskIDs)








    compliance=struct('SystemSID',{},'StatusArray',{});

    systemStatusArrayMap=containers.Map();

    for n=1:length(taskIDs)
        [status,systemSIDs]=app.getStatusForTask(taskIDs{n});

        for i=1:length(systemSIDs)
            if systemStatusArrayMap.isKey(systemSIDs{i})
                statusArray=systemStatusArrayMap(systemSIDs{i});
                statusArray(n)=status(i);
                systemStatusArrayMap(systemSIDs{i})=statusArray;
            else
                statusArray=repmat(uint8(3),size(taskIDs,1),size(taskIDs,2));
                statusArray(n)=status(i);
                systemStatusArrayMap(systemSIDs{i})=statusArray;
            end
        end
    end

    systems=systemStatusArrayMap.keys;

    for n=length(systems):-1:1
        system=systems{n};
        compliance(n).SystemSID=system;

        statusArray=systemStatusArrayMap(system);
        compliance(n).StatusArray=statusArray;
    end
end