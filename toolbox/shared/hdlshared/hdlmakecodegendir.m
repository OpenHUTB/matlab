function codegendir=hdlmakecodegendir


    codegendir=hdlGetCodegendir;

    [s,mess,messid]=mkdir(codegendir);
    if s==0
        switch lower(messid)
        case 'matlab:mkdir:directoryexists',
            error(message('HDLShared:directemit:directoryfailure',codegendir));
        case 'matlab:mkdir:oserror',
            error(message('HDLShared:directemit:directoryfailure2',codegendir));
        otherwise

            error(messid,mess);
        end
    end
