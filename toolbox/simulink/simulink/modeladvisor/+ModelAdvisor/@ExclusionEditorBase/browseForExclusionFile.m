function browseForExclusionFile(this)




    ext='.xml';
    text=DAStudio.message('ModelAdvisor:engine:PickExclusionFile');

    currPath=path;
    currWD=pwd;

    currFile='';
    currDir='';

    if~isempty(this.fileName)
        [currDir,currName]=fileparts(this.fileName);
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
        this.fileName=newFile;
    end
    this.applyExclusionFileChange;
    this.fDialogHandle.refresh;