function folder=getTargetRootFolder(target)





    folder='';
    targets=codertarget.target.getRegisteredTargetNames;
    folders=codertarget.target.getRegisteredTargetFolders;
    [found,index]=ismember(target,targets);
    if found
        folder=folders{index};
    end
end