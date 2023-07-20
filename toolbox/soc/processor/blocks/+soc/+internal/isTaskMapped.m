function ret=isTaskMapped(ModelName,taskName)







    ret=~isempty(soc.internal.getMappedTaskName(ModelName,taskName))+1;

end
