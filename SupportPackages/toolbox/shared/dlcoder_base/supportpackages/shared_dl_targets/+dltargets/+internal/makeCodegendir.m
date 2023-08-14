function codegendir=makeCodegendir(codegendir)


    if exist(codegendir,'dir')
        [s,mess,~]=rmdir(codegendir,'s');
        if s==0
            error(message('dlcoder_spkg:cnncodegen:rmDirfailure',mess));
        end
    end

    [s,mess,messid]=mkdir(codegendir);
    if s==0
        switch lower(messid)
        case 'matlab:mkdir:directoryexists'
            error(message('gpucoder:cnncodegen:directoryfailure',codegendir));
        case 'matlab:mkdir:oserror'
            error(message('gpucoder:cnncodegen:newdirectoryfailure',codegendir));
        otherwise

            error(messid,'%s',mess);
        end
    end



    tempFilePath=tempname(codegendir);
    fid=fopen(tempFilePath,'w');
    if fid==-1
        error(message('gpucoder:cnncodegen:readonlydirectoryfailure',codegendir));
    else
        fclose(fid);
        delete(tempFilePath);
    end



