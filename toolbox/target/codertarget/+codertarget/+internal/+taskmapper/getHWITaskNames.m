function taskNames=getHWITaskNames(modelName)




    hwiBlks=codertarget.internal.taskmapper.getHWIBlocksInModel(modelName);
    taskNames={};
    for i=1:numel(hwiBlks)

        taskNames(i)=get_param(hwiBlks(i),'Name');%#ok<AGROW>
    end
end