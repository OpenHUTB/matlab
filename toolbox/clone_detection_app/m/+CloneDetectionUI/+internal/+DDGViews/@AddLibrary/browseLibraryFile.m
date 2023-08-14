function browseLibraryFile(this)



    ext={'*.mdl;*.slx','Models (*.slx, *.mdl)'};
    text=DAStudio.message('sl_pir_cpp:creator:AddLibraryBrowserTitle');
    this.libFilenamesText='';
    currPath=path;
    currWD=pwd;

    dlgHandle=DAStudio.ToolRoot.getOpenDialogs(this);
    val=dlgHandle.getWidgetValue('fileOrFolderComboTag');
    if val==0

        [filename,pathname]=uigetfile(ext,text,'MultiSelect','on');

        if~isequal(filename,0)&&~isequal(pathname,0)

            cd(pathname);
            path(currPath);

            if ischar(filename)
                this.checkUploadedFileNameValidity(filename);

                newFile=fullfile(pathname,filename);
                for ii=1:length(this.cloneUIObj.libraryList)
                    if strcmp(this.cloneUIObj.libraryList{ii},newFile)
                        cd(currWD);
                        DAStudio.error('sl_pir_cpp:creator:LibAlreadyUploaded',...
                        this.cloneUIObj.libraryList{ii});
                    else
                        continue;
                    end
                end
                this.libFilenamesText=newFile;
            else
                for i=1:length(filename)


                    this.checkUploadedFileNameValidity(filename{i});
                end
                for i=1:length(filename)
                    newFile=fullfile(pathname,char(filename{i}));
                    this.libFilenamesText=[this.libFilenamesText,newFile,';'];
                end
            end

        else
            cd(currWD);
            return;
        end
    else

        folderName=uigetdir;
        if folderName==0
            cd(currWD);
            return
        else
            this.libFilenamesText=folderName;
        end
    end
    cd(currWD);

    dirtyEditor(this);

end