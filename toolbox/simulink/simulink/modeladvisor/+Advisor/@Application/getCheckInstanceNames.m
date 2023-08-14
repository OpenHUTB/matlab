function names=getCheckInstanceNames(this,taskIDs)

    maObj=this.getRootMAObj();
    names=cell(size(taskIDs));

    for n=1:length(taskIDs)
        taskObj=maObj.getTaskObj(taskIDs{n});
        names{n}=taskObj.DisplayName;
    end
end

