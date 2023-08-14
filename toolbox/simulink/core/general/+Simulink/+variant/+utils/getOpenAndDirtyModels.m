
function[openModels,dirtyModels]=getOpenAndDirtyModels()



    openModels=find_system('flat');
    dirtyModels=openModels(strcmp(get_param(openModels,'Dirty'),'on'));
end
