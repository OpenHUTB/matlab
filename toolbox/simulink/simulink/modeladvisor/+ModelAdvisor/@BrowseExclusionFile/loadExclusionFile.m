function loadExclusionFile(this)



    exclusionEditor=this.getExclusionEditor;


    if exclusionEditor.getUnsavedChanges
        qstring=DAStudio.message('ModelAdvisor:engine:LoadPopUpQuestion');
        title=DAStudio.message('ModelAdvisor:engine:LoadTitle');
        button=questdlg(qstring,title,'Yes','No','Yes');
        if strcmp(button,'No')
            return;
        end
    end

    ext='.xml';
    text=DAStudio.message('ModelAdvisor:engine:PickExclusionFile');

    currPath=path;
    currWD=pwd;

    currFile='';
    currDir='';

    if~isempty(exclusionEditor.fileName)
        [currDir,currName]=fileparts(exclusionEditor.fileName);
        if~isempty(currDir)&&exist(currDir,'dir')~=0
            addpath(currDir);
        end
        currFile=which([currName,ext]);
    end

    if exist(currDir,'dir')==0
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
        [~,~,ext]=fileparts(filename);
        if~strcmpi(ext,'.xml')
            errordlg(DAStudio.message('ModelAdvisor:engine:FileShouldBeXML'));
            return;
        end
        newFile=fullfile(pathname,filename);
    else
        return;
    end

    if~isempty(newFile)
        exclusionEditor.fileName=newFile;
    end
    exclusionEditor.applyExclusionFileChange;
    exclusionEditor.fDialogHandle.refresh;
    exclusionEditor.fDialogHandle.enableApplyButton(false);
    this.delete;