function onChangeShowFullPath(this,dlg)




    nFiles=numel(this.BuildInfo.SourceFiles.FilePath);
    if(this.ShowFullFilePath)
        for m=1:nFiles
            this.FileTableData{m,1}=this.BuildInfo.SourceFiles.FilePath{m};
        end
    else
        for m=1:nFiles
            [~,name,ext]=fileparts(this.BuildInfo.SourceFiles.FilePath{m});
            this.FileTableData{m,1}=[name,ext];
        end
    end
    dlg.refresh;
