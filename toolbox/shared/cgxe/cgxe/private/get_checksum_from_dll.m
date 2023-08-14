function checksum=get_checksum_from_dll(modelName)



    dllName=[modelName,'_cgxe'];
    dllFileName=[dllName,'.',mexext];

    try

        args{1}='get_checksums';
        checksum=feval(dllName,args{:});

        dllDirInfo=dir(which(dllFileName));
        checksum.saveDate=dllDirInfo.datenum;

    catch ME %#ok

        checksum.modules={};
        checksum.model=[];
        checksum.makefile=[];
        checksum.target=[];
        checksum.overall=[];
        checksum.saveDate=0.0;

    end
