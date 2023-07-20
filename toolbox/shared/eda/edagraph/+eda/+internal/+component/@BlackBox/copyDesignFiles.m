function copyDesignFiles(this)





    usrDir=hdlGetCodegendir(true);
    srcDir=this.HDLFileDir;

    if exist(usrDir,'dir')~=7
        mkdir(usrDir);
    end
    if~isa(srcDir,'cell')
        srcDir={srcDir};
    end
    if length(srcDir)==1
        srcDir=repmat(srcDir,length(this.HDLFiles),1);
    end
    for i=1:length(this.HDLFiles)
        srcFile=this.HDLFiles{i};
        header=hdlCopyRightHeader(srcFile);
        if~strcmp(usrDir,srcDir)
            copyfile(fullfile(srcDir{i},srcFile),fullfile(usrDir,srcFile),'f');
            fileattrib(fullfile(usrDir,srcFile),'+w');
            newFile=fopen(fullfile(usrDir,srcFile),'r');
            origFileContent=fread(newFile,'*char')';
            fclose(newFile);
            newFile=fopen(fullfile(usrDir,srcFile),'w');
            fwrite(newFile,sprintf(header));
            fwrite(newFile,origFileContent);
            fclose(newFile);

        end
    end

    srcDir=this.NetListDir;
    if~isa(srcDir,'cell')
        srcDir={srcDir};
    end
    if length(srcDir)==1
        srcDir=repmat(srcDir,length(this.NetList),1);
    end
    for i=1:length(this.NetList)
        srcFile=this.NetList{i};
        if~strcmp(usrDir,srcDir)
            copyfile(fullfile(srcDir{i},srcFile),fullfile(usrDir,srcFile),'f');
        end
    end

    srcDir=this.ScriptDir;
    if~isa(srcDir,'cell')
        srcDir={srcDir};
    end
    if length(srcDir)==1
        srcDir=repmat(srcDir,length(this.ScriptDir),1);
    end
    for i=1:length(this.Script)
        srcFile=this.Script{i};
        if~strcmp(usrDir,srcDir)
            copyfile(fullfile(srcDir{i},srcFile),fullfile(usrDir,srcFile),'f');
        end
    end
end

