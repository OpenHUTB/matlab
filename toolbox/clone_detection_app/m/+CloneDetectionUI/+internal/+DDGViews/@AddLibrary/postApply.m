function[status]=postApply(this)




    status=true;
    if~isempty(this.libFilenamesText)
        val=this.fDialogHandle.getWidgetValue('fileOrFolderComboTag');
        if val==0

            if~contains(this.libFilenamesText,';')

                if~checkUploadedFileNameValidity(this,this.libFilenamesText)
                    return;
                end
                this.cloneUIObj.libraryList=[this.cloneUIObj.libraryList;{this.libFilenamesText}];
            else

                libNamecellArray=(strsplit(this.libFilenamesText,';'))';
                len=length(libNamecellArray);
                for i=1:(len-1)
                    if~checkUploadedFileNameValidity(this,char(libNamecellArray{i}))
                        return;
                    end
                end
                this.cloneUIObj.libraryList=[this.cloneUIObj.libraryList;libNamecellArray(1:len-1)];
            end

        else

            folderName=this.libFilenamesText;
            this.files=[];
            this.getLibFilesFromDir(folderName);
            mask=false(1,length(this.files));
            for i=1:length(this.files)


                if~this.checkUploadedFileNameValidity(char(this.files{i}))
                    mask(i)=1;
                    continue;
                end
            end
            this.files(mask)=[];
            this.cloneUIObj.libraryList=[this.cloneUIObj.libraryList;this.files];
            this.files=[];
        end
        this.libFilenamesText='';
        this.fDialogHandle.setTitle(this.title);
        this.setUnsavedChanges(false);
        this.fDialogHandle.refresh;

        this.cloneUIObj.toolstripCtx.enableReplaceWithSSRef=isempty(this.cloneUIObj.libraryList);

        CloneDetectionUI.internal.util.saveCloneDetectionUIObjToLatestVersion(this.model);
    end
end

