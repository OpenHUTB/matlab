function browseForExclusionFile(this)




    ext='.xml';
    text=DAStudio.message('ModelAdvisor:engine:PickExclusionFile');

    currPath=path;
    currWD=pwd;

    currFile='';
    currDir='';

    editor=this.getExclusionEditor();

    if~isempty(editor.fileName)
        [currDir,currName]=fileparts(editor.fileName);
        if~isempty(currDir)
            addpath(currDir);
        end

        currFile=which([currName,ext]);
    end

    if isempty(currFile)||strcmp(currFile,'built-in')||strcmp(currFile,'variable')
        currFile='';
        currDir='';
    end

    if~isempty(currDir)
        cd(currDir);
    end

    [filename,pathname]=uigetfile(ext,text,currFile);

    cd(currWD);
    path(currPath);

    if~isequal(filename,0)&&~isequal(pathname,0)
        newFile=fullfile(pathname,filename);
        [~,newFile,~]=fileparts(newFile);
    else
        return;
    end

    newFile=[newFile,'.xml'];

    if~isempty(newFile)
        this.fileName=newFile;
    end
    this.fDialogHandle.refresh;
    this.fDialogHandle.enableApplyButton(true);
