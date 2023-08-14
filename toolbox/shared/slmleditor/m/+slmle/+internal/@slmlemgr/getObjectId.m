function objectId=getObjectId(obj,block)


    [path,name,~]=fileparts(block);
    rt=sfroot;


    emfs=rt.find('-isa','Stateflow.EMFunction');
    for i=1:length(emfs)
        if(strcmp(emfs(i).Path,path)&&strcmp(emfs(i).Name,name))
            objectId=emfs(i).Id;
            return;
        end
    end


    chartId=obj.getChartId(block);
    objectId=sf('get',chartId,'.states');


end

