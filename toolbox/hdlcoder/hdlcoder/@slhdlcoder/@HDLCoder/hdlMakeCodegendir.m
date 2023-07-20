function codegendir=hdlMakeCodegendir(this)


    codegendir=this.hdlGetCodegendir;
    if codegendir(1)~=filesep

        existcodegendir=['.',filesep,codegendir];
    else
        existcodegendir=codegendir;
    end
    if~exist(existcodegendir,'dir')
        [s,mess,messid]=mkdir(codegendir);
        if s==0
            switch lower(messid)
            case 'matlab:mkdir:directoryexists'
                error(message('hdlcoder:engine:directoryfailure',codegendir));
            case 'matlab:mkdir:oserror'
                error(message('hdlcoder:engine:newdirectoryfailure',codegendir));
            otherwise

                error(messid,'%s',mess);
            end
        end
    end


    tempFilePath=tempname(codegendir);
    fid=fopen(tempFilePath,'w');
    if fid==-1
        error(message('hdlcoder:engine:readonlydirectoryfailure',codegendir));
    else
        fclose(fid);
        delete(tempFilePath);
    end


