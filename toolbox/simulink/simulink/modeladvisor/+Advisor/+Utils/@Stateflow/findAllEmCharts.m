











function[linkStatus,emCharts,modelPath]=findAllEmCharts(system)
    sysObj=get_param(system,'Object');
    emCharts=sysObj.find('-isa','Stateflow.EMChart');
    linkStatus=zeros(size(emCharts));
    modelPath=cell(size(emCharts));
    for idx=1:length(emCharts)
        modelPath{idx}=emCharts(idx).Path;
    end
    linkCharts=sysObj.find('-isa','Stateflow.LinkChart');
    for i=1:length(linkCharts)
        lcHndl=sf('get',linkCharts(i).Id,'.handle');
        cId=sfprivate('block2chart',lcHndl);
        c=idToHandle(sfroot,cId);
        if c.isa('Stateflow.EMChart')
            emCharts(end+1)=c;%#ok<AGROW> no prealloc
            linkStatus(end+1)=1;%#ok<AGROW> no prealloc
            modelPath{end+1}=linkCharts(i).Path;%#ok<AGROW> no prealloc
        end
    end
end

