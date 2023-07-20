function output=getOrganizeLayout(h,layoutFilesPath)




    dialog=createCustomDialog(h,'OrganizeLayout');
    setLayoutPath(dialog,layoutFilesPath);
    output=true;

    selection=dialog.run;

    while~isempty(selection)






        renameDialog=createCustomDialog(h,'LayoutName');
        newName=renameDialog.run;
        if~isempty(newName)

            oldFile=selection.Value;
            [path,~,ext]=fileparts(oldFile);
            newFullFile=fullfile(path,strcat(newName,ext));
            if~isequal(oldFile,newFullFile)

                movefile(oldFile,newFullFile);
            end
        end

        dialog=createCustomDialog(h,'OrganizeLayout');
        setLayoutPath(dialog,layoutFilesPath);
        selection=dialog.run;
    end
