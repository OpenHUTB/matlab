function taskNames=findHWITaskNames(modelName)




    hwiBlks=codertarget.internal.taskmapper.findHWI(modelName);
    taskNames={};
    for i=1:numel(hwiBlks)

        taskNames(i)=get_param(hwiBlks(i),'Name');%#ok<AGROW>
    end

end