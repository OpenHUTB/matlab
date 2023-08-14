function tbopenfile(this)

    tbfiles={};



    tbfilename=fullfile(this.CodeGenDirectory,...
    [this.TestBenchName,this.TBFileNameSuffix]);
    fileId=fopen(tbfilename,'W');
    if fileId==-1
        error(message('HDLShared:hdlshared:fileerror',tbfilename));
    else
        this.tbFileId=fileId;
        tbfiles(end+1)={[this.TestBenchName,this.TBFileNameSuffix]};
    end


    if strcmpi(this.TestBenchdataFile,'on')
        dataFileName=fullfile(this.CodeGenDirectory,...
        [this.TestBenchName,this.TestBenchDataPostfix,this.TBFileNameSuffix]);
        fileId=fopen(dataFileName,'W');
        if fileId==-1
            error(message('HDLShared:hdlshared:fileerror',dataFileName));
        else
            this.tbDataFileId=fileId;
            tbfiles(end+1)={[this.TestBenchName,this.TestBenchDataPostfix,this.TBFileNameSuffix]};
        end
    else
        this.tbDataFileId=this.tbFileId;
    end


    pkgFileName=fullfile(this.CodeGenDirectory,...
    [this.TestBenchName,hdlgetparameter('package_suffix'),this.TBFileNameSuffix]);

    if strcmpi(this.testBenchPackageFile,'on')
        fileId=fopen(pkgFileName,'W');
        if fileId==-1
            error(message('HDLShared:hdlshared:fileerror',pkgFileName));
        else
            this.tbPkgFileId=fileId;
            tbfiles(end+1)={[this.TestBenchName,hdlgetparameter('package_suffix'),this.TBFileNameSuffix]};
        end
    else
        this.tbPkgFileId=this.tbFileId;
    end


    if hdlgetparameter('isvhdl')
        for i=1:length(tbfiles)
            this.TestBenchFilesList(end+1)=tbfiles(length(tbfiles)-i+1);
        end
    else
        this.TestBenchFilesList(end+1)=tbfiles(1);
    end

    this.printFileLink;
end
