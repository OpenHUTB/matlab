function browseFolders(obj)



    currWD=pwd;


    folderName=uigetdir;
    if folderName==0
        cd(currWD);
        return
    else
        obj.selectedFolders{end+1,1}=folderName;
    end



    dirtyEditor(obj);

end
