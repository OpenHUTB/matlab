function result=isInLockedLibrary(hBlock)




    rootModel=bdroot(hBlock);
    result=bdIsLibrary(rootModel)&&strcmp(get_param(rootModel,'Lock'),'on');
end
