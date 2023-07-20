function indx=fileTypeStr2Int(this,str)




    FileTypeEnum=this.BuildInfo.getFileTypes;

    indx=find(strcmp(str,FileTypeEnum),1);
    if(isempty(indx))
        indx=1;
    end
