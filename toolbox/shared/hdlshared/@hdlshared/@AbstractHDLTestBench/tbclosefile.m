function tbclosefile(this)



    if this.tbFileId>0
        fclose(this.tbFileId);
    end

    if this.tbPkgFileId>0&&this.tbPkgFileId~=this.tbFileId
        fclose(this.tbPkgFileId);
    end

    if this.tbDataFileId>0&&this.tbDataFileId~=this.tbFileId&&this.tbDataFileId~=this.tbPkgFileId
        fclose(this.tbDataFileId);
    end