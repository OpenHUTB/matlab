function[notfound,warnings]=loadlibrary(library,header,varargin)




























































    if nargin>0
        library=convertStringsToChars(library);
    end

    if nargin>1
        header=convertStringsToChars(header);
    end

    if nargin>2
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    if(nargin==0)
        error(message('MATLAB:loadlibrary:NotEnoughInputs'));
    end

    createThunk=false;
    needsthunk=false;


    uselcc64=false;

    if isempty(regexp(computer,'^(PCWIN|GLNX86|MACI)$'))%#ok
        needsthunk=true;
    end
    SharedLibExt=system_dependent('GetSharedLibExt');


    thunkfilename='';
    cleanupTempFiles=true;
    usetempdir=true;
    perlopt={};
    parsemsg=[];
    classname=[];
    mfile_name=[];
    protofunction=[];
    ccinclude=[];
    nocpp=false;
    mode=1;
    genMfile=false;
    debug=false;
    delfiles={};
    workingDir='';
    cleanupDirOnUnload='';
    warnings='';
    compilerConfiguration=[];

    if nargin>2
        i=1;
        while i<=length(varargin)
            str=varargin{i};
            if~ischar(str)
                error(message('MATLAB:loadlibrary:OptionsMustBeStrings'));
            end
            switch(str)
            case 'notempdir'
                usetempdir=false;
                cleanupTempFiles=false;
                genMfile=true;
            case 'alias'
                i=i+1;
                classname=varargin{i};
            case 'nocpp'
                nocpp=true;
            case 'mpar'
                mode=2;
            case 'ppar'
                mode=1;
            case 'includepath'
                i=i+1;


                ccinclude=[ccinclude,' -I',quoteFilename(regexprep(varargin{i},'[\\/]$',''))];%#ok<*AGROW>
            case 'mfilename'
                i=i+1;
                mfile_name=varargin{i};
                usetempdir=false;
                genMfile=true;
            case 'addheader'
                i=i+1;
                perlopt{end+1}=varargin{i};
            case 'debug'
                if i<length(varargin)
                    i=i+1;
                    perlopt{end+1}=['-debug=',varargin{i}];
                else
                    perlopt{end+1}='-debug';
                end
                debug=true;
            case 'thunkfilename'
                usetempdir=false;
                i=i+1;
                thunkfilename=varargin{i};
                if~isempty(thunkfilename)
                    createThunk=true;
                else
                    if needsthunk
                        warning(message('MATLAB:loadlibrary:thunkneeded'));
                        needsthunk=false;
                    end
                end
            case 'createThunk'
                createThunk=true;
            case 'compilerconfiguration'
                i=i+1;
                compilerConfiguration=varargin{i};
            case 'uselcc64'
                if(strcmp(computer('arch'),'win64'))
                    uselcc64=true;
                else
                    error(message('MATLAB:loadlibrary:InvalidOption',str));
                end
            otherwise
                error(message('MATLAB:loadlibrary:InvalidOption',str));
            end
            i=i+1;
        end
    end

    try
        librarypath=lFullPath(library,SharedLibExt);
    catch exception

        if~strcmp(exception.identifier,'MATLAB:loadlibrary:FileNotFound')
            throw(exception);
        end
        librarypath=library;
    end
    [~,libname]=fileparts(librarypath);

    if isempty(classname)
        classname=genvarname(libname);
        if strcmp(classname,libname)~=1
            warning(message('MATLAB:loadlibrary:ClassRenamed',classname));
        elseif isempty(regexp(library,[libname,'(\.[^.\\/]+)?$'],'once'))
            warning(message('MATLAB:loadlibrary:ClassCaseMismatch',classname));
        end
    end

    if libisloaded(classname)
        warning(message('MATLAB:loadlibrary:ClassIsLoaded',classname));
        if(nargout>=1)
            notfound=[];
        end
        return;
    end


    if nargin==1
        header=libname;
    end

    if isa(header,'function_handle')
        mode=3;
    elseif ischar(header)
        [headerpath,headername,headerext]=fileparts(header);
        ftype=exist(header,'file');
        if ftype==0||ftype==3
            if isempty(headerext)
                header=strcat(header,'.h');
                headerext='.h';
            end
        end
        switch headerext
        case '.i'
            nocpp=true;
        case '.mat'
            mode=4;
            nocpp=true;
            usetempdir=false;
        case ''
            if strcmp(headername,header)&&~isempty(which(header))
                mode=3;

            end
        otherwise

        end
        if mode<3
            header=lFullPath(header);
            [headerpath,headername]=fileparts(header);
        end
    else
        error(message('MATLAB:loadlibrary:InvalidSecondArgument'));
    end


    if(mode==3)
        nocpp=true;
        usetempdir=false;
        if(nargin>=2)
            if isa(header,'function_handle')
                protofunction=header;
            else
                protofunction=headername;
            end
        end
    elseif mode<=2
        if isdeployed
            error(message('MATLAB:loadlibrary:NoHeaderAllowed'));
        end
        if mode==1
            prototypes=which('prototypes.pl');
        end
        if needsthunk
            createThunk=true;
        end
        if(nocpp)
            preprocfile=header;
        else
            preprocfile=[headername,'.i'];
            delfiles{end+1}=preprocfile;
        end
        [thunk_build_fn,preprocess_command,noCompiler]=getLoadlibraryCompilerConfiguration(ccinclude,header,headername,compilerConfiguration,uselcc64);
    end

    if isempty(protofunction)&&(mode==1||mode==3)
        if isempty(mfile_name)
            protofunction=genvarname([classname,'_proto']);
            mfile_name=[protofunction,'.m'];
            if~genMfile
                delfiles{end+1}=mfile_name;
            end
        else
            [~,fn]=fileparts(mfile_name);
            mfile_name=[fn,'.m'];
            protofunction=fn;
        end
    end


    if createThunk
        if isempty(thunkfilename)
            thunkfilename=[classname,'_thunk_',lower(computer)];

        end
        pwdstr=pwd;
        if(~isempty(pwdstr)&&pwdstr(end)=='\')
            pwdstr=[pwdstr,'\'];
        end
        additional_thunk_includes=['-I',quoteFilename(pwdstr)];
        if~isempty(headerpath)
            additional_thunk_includes=[additional_thunk_includes,' -I',quoteFilename(headerpath)];
        end

        if regexp(thunkfilename,'^([a-zA-Z]:)?[\\/]')~=1
            thunkfilename=[pwd,filesep,thunkfilename];
        end

        thunkfilecname=[thunkfilename,'.c'];
        delfiles{end+1}=thunkfilecname;
    end


    if genMfile&&isempty(mfile_name)
        protofunction=genvarname([classname,'_proto']);
        mfile_name=[protofunction,'.m'];
    end

    if~isa(protofunction,'function_handle')&&exist(protofunction,'file')==3&&strcmpi(protofunction,libname)
        error(message('MATLAB:loadlibrary:invalid_mfilename'));
    end


    savedir=pwd;
    restoreOriginalPwd=onCleanup(@()cd(savedir));
    try
        stage='Preprocess';
        if usetempdir
            workingDir=tempname;
            mkdir(workingDir);
            cd(workingDir);
        else
            workingDir='';
        end
        if(~nocpp)
            [res,ccout]=system(preprocess_command);
            if(res~=0)
                error(message('MATLAB:loadlibrary:cppfailure',ccout));
            end


            if(res==0&&~isempty(regexpi(ccout,'\<(warning|error)\>','once')))
                warning(message('MATLAB:loadlibrary:cppoutput',ccout));
            end
            warnings=[warnings,ccout];
        end

        if mode==1
            clear(protofunction);





            if createThunk
                [parsemsg,status]=perl(prototypes,preprocfile,['-outfile=',mfile_name],...
                ['-thunkfile=',thunkfilecname],['-header=',headername,headerext],perlopt{:});
            else
                [parsemsg,status]=perl(prototypes,preprocfile,['-outfile=',mfile_name],...
                perlopt{:});
            end
            warnings=[warnings,parsemsg];
            if status<0||status>1
                error(message('MATLAB:loadlibrary:cannotgeneratemfile',parsemsg));
            elseif nargout<2
                if debug
                    disp(parsemsg);
                elseif status==1
                    warning(message('MATLAB:loadlibrary:parsewarnings'));
                end
            end
            loop=1;
            fschange(pwd);
            while~isfile(mfile_name)
                if(loop>256)
                    error(message('MATLAB:loadlibrary:PrototypeFileNotFound'));
                end
                pause(loop*0.01);
                fschange(pwd);
                loop=loop*2;
            end
            clear loop;
        end


        if createThunk
            if isempty(thunkfilename)
                error(message('MATLAB:loadlibrary:EmptyThunkfileNames'));
            end
            if(noCompiler&&uselcc64)

                [status,results]=buildThunkwithCC(ccinclude,additional_thunk_includes,thunkfilecname,thunkfilename,SharedLibExt);
            else
                [status,results]=thunk_build_fn(additional_thunk_includes,thunkfilecname,addfileext(thunkfilename,SharedLibExt));
                warnings=[warnings,results];
            end
            if(status~=0)


                coderDiagnostic=diagnoseERTSharedLibrary(results);
                errormsg=message('MATLAB:loadlibrary:CompileFailed',thunkfilename,results).getString;
                if(~isempty(coderDiagnostic))
                    errormsg=sprintf('%s\n\n%s',errormsg,coderDiagnostic);
                end
                error(errormsg);
            end
            cleanupDirOnUnload=workingDir;
        end

        if mode==1||mode==3
            stage='RunFn';
            try
                [fcns,structs,enums,thunkfilename]=feval(protofunction);
            catch err
                if strcmp(err.identifier,'MATLAB:TooManyOutputs')
                    warning(message('MATLAB:loadlibrary:OldStyleMfile'));
                    [fcns,structs,enums]=feval(protofunction);
                else
                    err.rethrow;
                end
            end
        elseif mode==2
            stage='mparc';
            [fcns,structs,enums]=mparc(preprocfile);

            if genMfile
                mcheaderexternal(fcns,structs,enums,mfile_name);
            end
        else

            load(header);
        end

        stage='LoadDefined';
        if~isempty(thunkfilename)
            thunkfilename=addfileext(thunkfilename,SharedLibExt);
        end

        delete(restoreOriginalPwd);

        loaddefinedlibrary(librarypath,fcns,classname,structs,enums,thunkfilename,cleanupDirOnUnload);

        deltempfiles(delfiles,cleanupTempFiles,workingDir,~createThunk&&usetempdir);

        if(nargout>=1)
            loaded=methods(['lib.',classname]);
            if(isempty(loaded))
                warning(message('MATLAB:loadlibrary:nofunctions'));
                notfound=fcns.name;
            else
                notfound=setdiff(fcns.name,loaded,'legacy');
            end
        end
    catch exception
        clear restoreOriginalPwd;
        deltempfiles(delfiles,cleanupTempFiles,workingDir,usetempdir);
        throw(diagnoseError(exception,stage,mode));
    end

    function err=diagnoseError(err,stage,mode)


        loaderError=false;
        switch(stage)
        case 'RunFn'
            loaderError=true;
        case 'LoadDefined'
        otherwise
        end
        if~any(strcmp(err.identifier,...
            {'MATLAB:UndefinedFunction','MATLAB:loadlibrary:LoadFailed'}))||debug
            if~isempty(parsemsg)
                disp(getString(message('MATLAB:loadlibrary:IntermediateOutputFollows')))
                disp(getString(message('MATLAB:loadlibrary:ActualErrorAtEndOfOutput')));
                fprintf('*********\n%s*********\n',parsemsg);
            end
            if loaderError
                if(length(err.stack)>1)
                    location=err.stack(1);
                else
                    location=regexp(err.message,...
                    'Line:\s+(?<line>\d+)\s+Column:\s+(?<column>\d+)','names');
                    if numel(location)>=1
                        location.line=str2double(location.line);
                        location.file=mfile_name;
                        if isa(protofunction,'function_handle')
                            location.name=func2str(protofunction);
                        else
                            location.name=protofunction;
                        end
                    end
                end

                if mode>2&&~isempty(location)
                    new_err=MException(err.identifier,'%s\n%s\n',getString(message('MATLAB:loadlibrary:ErrorInHeader',err.message,location.name,location.line)),getString(message('MATLAB:loadlibrary:ErrorRunningFromCommandLine',...
                    location.file,location.name)));
                else
                    new_err=MException(err.identifier,'\n%s',getString(message('MATLAB:loadlibrary:ErrorRunningLoaderFile')));
                end
                new_err=addCause(new_err,err);
                new_err.throwAsCaller;
            end
        else
            new_err=MException(err.identifier,'%s',getString(message('MATLAB:loadlibrary:ErrorLoadingLibrary',librarypath,err.message)));
            new_err=addCause(new_err,err);
            new_err.throwAsCaller;
        end
        if(~isempty(regexp(err.identifier,':loadlibrary:','once')))
            throwAsCaller(err);
        else
            rethrow(err);
        end

    end
end

function fixed=fixesc(input)
    fixed=strrep(input,'\','\\');
    fixed=strrep(fixed,'%','%%');
end

function[thunk_build_fn,preprocess_command,noCompiler]=getLoadlibraryCompilerConfiguration(ccinclude,header,headername,compilerConfiguration,uselcc64)
    noCompiler=false;
    thunk_build=[];
    thunk_build_fn=[];
    if isempty(compilerConfiguration)
        try
            compilerConfiguration=mex.getCompilerConfigurations('C','Selected');
            if(isempty(compilerConfiguration)&&uselcc64)
                preprocess_command=getCCPreprocessCommand(ccinclude,header);
                noCompiler=true;
                return;
            end
        catch e
            throwAsCaller(e)
        end
        if(~isempty(compilerConfiguration))
            compilerConfiguration=compilerConfiguration(1);
        else

            archstr=computer('arch');

            if(strcmp(archstr,'win64'))
                if(usejava('jvm'))
                    error(message('MATLAB:mex:NoCompilerFound_link_Win64'));
                else
                    error(message('MATLAB:mex:NoCompilerFound_Win64'));
                end
            elseif(usejava('jvm'))
                error(message('MATLAB:mex:NoCompilerFound_link'));
            else
                error(message('MATLAB:mex:NoCompilerFound'));
            end
        end
    end
    Details=compilerConfiguration.Details;
    cc=Details.CompilerExecutable;
    build_opt=fixesc(Details.CompilerFlags);
    if ispc
        SystemDetails=Details.SystemDetails;
        restorematlab=protectEnvAddition('matlab',matlabroot);%#ok<NASGU> return value is an onCleanup object
        restorepath=protectEnvAddition('path',SystemDetails.SystemPath);%#ok<NASGU> 
        restoreinclude=protectEnvAddition('include',SystemDetails.IncludePath);%#ok<NASGU> 
        restorelib=protectEnvAddition('lib',SystemDetails.LibraryPath);%#ok<NASGU> 
    end
    ccinclude=[ccinclude,' -I',quoteFilename(fullfile(matlabroot,'extern','include'))];

    switch(compilerConfiguration.Manufacturer)
    case{'Microsoft','Intel'}

        build_opt=regexprep(build_opt,'\<[\-/](c|MD|GR|EHs|DMATLAB_MEX_FILE)\>','');
        thunk_build=[fixesc(cc),fixesc(ccinclude),' ',build_opt,' %s "%s" -LD -Fe"%s"'];
        preprocess_command=[cc,ccinclude,' ',build_opt,' -E "',header,'" > "',headername,'.i"'];
        if strcmp(compilerConfiguration.Manufacturer,'Microsoft')&&strcmp(compilerConfiguration.Version,'6.0')
            thunk_build_fn=@(varargin)noThunkingError('MATLAB:loadlibrary:ThunkfileNotSupportedbyMSVC6','The Microsoft Visual C 6.0 compiler cannot be used to build a thunk file.');
        end
    case 'LCC'
        build_opt=regexprep(build_opt,'\<[\-/](c|DMATLAB_MEX_FILE)\>','');

        thunk_build_fn=@(varargin)noThunkingError('MATLAB:loadlibrary:ThunkfileNotSupportedbyLCC','The LCC compiler cannot be used to build a thunk file.');
        build_opt=strrep(build_opt,'%%MATLAB%%','%MATLAB%');
        preprocess_command=[cc,' ',build_opt,ccinclude,' -E ',quoteFilename(header)];
    case 'Sybase'
        build_opt=regexprep(build_opt,'\<[\-/](c|DMATLAB_MEX_FILE)\>','');
        preprocess_command=[cc,ccinclude,' ',build_opt,' -pl "',header,'" > "',headername,'.i"'];
        thunk_build=[fixesc(cc),fixesc(ccinclude),' ',build_opt,' %s "%s" %s'];
        thunk_build_fn=@watcomThunkBuilder;
    case 'GNU'

        build_opt=regexprep(build_opt,'\<-ansi\>','');
        wle='';
        if strcmpi(computer,'GLNXA64')

            wle='-Wl,-E ';
        end


        thunk_build=[fixesc(cc),fixesc(ccinclude),' '...
        ,fixesc(build_opt),' %s "%s" -o "%s" ',wle,'-shared '];

        preprocess_command=[cc,ccinclude,' ',build_opt,' -x c -E "',header,'" > "',headername,'.i"'];
    case 'Apple'
        a=regexp(build_opt,'-isysroot\s+\$MW_SDKROOT');
        if(~isempty(a))
            content=fileread(compilerConfiguration.MexOpt);
            [~,~,~,~,~,tmpval]=regexp(content,'MW_SDKROOT=`(?<Name>[^"]+)`');
            if(strcmp(tmpval.Name,'$MW_SDKROOT_TMP'))
                [~,~,~,~,~,val]=regexp(content,'MW_SDKROOT_TMP="(?<Name>[^"]+)"');
                [status,out]=system(val.Name);
                if(status==0)
                    if(strcmp(out(end),char(10)))
                        out=out(1:end-1);
                    end
                    build_opt=strrep(build_opt,'$MW_SDKROOT',out);
                end
            end
        end
        build_opt=regexprep(build_opt,{'$ARCHS','\-[\w\-]+[\s=]+\$\w+'},{'x86_64',''});
        thunk_build=[cc,ccinclude,' ',fixesc(build_opt),' %s "%s" -o "%s" -bundle '];
        preprocess_command=[cc,ccinclude,' ',build_opt,' -x c -E "',header,'" > "',headername,'.i"'];
    otherwise
        error(message('MATLAB:loadlibrary:UnsupportedCompiler'));
    end
    if isempty(thunk_build_fn)
        thunk_build_fn=@thunkBuilder;
    end
    function[status,output]=thunkBuilder(additional_thunk_includes,thunkfilecname,thunklibname)
        cmd=sprintf(thunk_build,additional_thunk_includes,thunkfilecname,thunklibname);
        [status,output]=system(cmd);
        if status~=0
            output=sprintf('%s\n%s',cmd,output);
        end
    end
    function[status,output]=watcomThunkBuilder(additional_thunk_includes,thunkfilecname,thunklibname)
        [status,output]=thunkBuilder(additional_thunk_includes,thunkfilecname,'');
        if status==0
            thunkexe=regexprep(thunkfilecname,'\.c$','.exe');
            movefile(thunkexe,thunklibname);
        end
    end

    function[foo,bar]=noThunkingError(id,msg)%#ok<STOUT>
        e=MException(id,msg);
        throwAsCaller(e);
    end
end

function restore=protectEnvAddition(var,add)
    if isempty(add)
        restore=[];
    else
        oldvalue=getenv(var);
        restore=onCleanup(@()setenv(var,oldvalue));
        new=regexprep(add,'%(\w+)%','${getenv($1)}');
        setenv(var,new);
    end
end

function filepath=lFullPath(srcfile,ext)


    filepath=which(srcfile);
    if isempty(filepath)&&nargin==2
        filepath=lFullPath(addfileext(srcfile,ext));
    elseif isempty(filepath)||(isfile(filepath)&&strcmpi(filepath(end-1:end),'.m'))

        if~isempty(dir(fullfile(pwd,srcfile)))
            srcfile=fullfile(pwd,srcfile);
        end
        if isempty(dir(srcfile))
            error(message('MATLAB:loadlibrary:FileNotFound',srcfile));
        end
        filepath=srcfile;
    end
end

function fname=addfileext(fname,ext)

    ind=regexp(fname,'\.[^.\\/]*$');%#ok<RGXP1>
    if isempty(ind)
        fname=[fname,ext];
    end
end

function filename=quoteFilename(filename)
    filename=['"',filename,'"'];
end

function deltempfiles(tempfiles,cleanup,tempdir,removeTempDir)
    if cleanup
        for i=tempfiles
            if isempty(fileparts(i{1}))
                fname=fullfile(tempdir,i{1});
            else
                fname=i{1};
            end
            if isfile(fname)
                delete(fname);
            end
        end
        if removeTempDir
            try
                rmdir(tempdir,'s');
            catch e
                dirNotRemovedExpToIgnore={'MATLAB:RMDIR:NoDirectoriesRemoved','MATLAB:RMDIR:SomeDirectoriesNotRemoved'};
                if(~any(strcmp(dirNotRemovedExpToIgnore,e.identifier)))
                    rethrow(e);
                end
            end
        end
    end
end

function preprocess_command=getCCPreprocessCommand(ccinclude,header)
    lcc64_exe=['"',matlabroot,'\sys\lcc64\lcc64\bin\lcc64.exe','"',' -dll',' -noregistrylookup',' -DLCC_WIN64',' -D__fastcall=',' -c ',' -Zp8',' -nodeclspec'];
    ccinclude=[ccinclude,' -I',quoteFilename(fullfile(matlabroot,'extern','include')),' -I',quoteFilename(fullfile(matlabroot,'sys','lcc64','lcc64','include64'))];
    preprocess_command=[lcc64_exe,ccinclude,' ',' -E',' ',quoteFilename(header)];
end

function[status,results]=buildThunkwithCC(ccinclude,additional_thunk_includes,thunkfilecname,thunkfilename,SharedLibExt)
    lcc64_exe=['"',matlabroot,'\sys\lcc64\lcc64\bin\lcc64.exe','"',' -dll',' -noregistrylookup',' -DLCC_WIN64',' -D__fastcall=',' -c',' -Zp8',' -nodeclspec'];
    ccinclude=[ccinclude,' -I',quoteFilename(fullfile(matlabroot,'extern','include')),' -I',quoteFilename(fullfile(matlabroot,'sys','lcc64','lcc64','include64'))];

    stubnamewithpath=[matlabroot,'\sys\lcc64\lcc64\mex\lccstub.c'];
    stubname='lccstub';
    lcc64link_exe=['"',matlabroot,'\sys\lcc64\lcc64\bin\lcclnk64.exe','"',' -s',' -dll',' -L','"'...
    ,matlabroot,'\sys\lcc64\lcc64\lib64','"',' -entry',' LibMain',' -o'];
    lcc64_compile_thunk=[lcc64_exe,ccinclude,' ',additional_thunk_includes,' "',thunkfilecname,'"'];
    [status,results]=system(lcc64_compile_thunk);

    if(status==0)
        lcc64_compile_stub=[lcc64_exe,ccinclude,' ',additional_thunk_includes,' "',stubnamewithpath,'"'];
        system(lcc64_compile_stub);
        lcc64_link=[lcc64link_exe,' ',addfileext(thunkfilename,SharedLibExt),' "',thunkfilename,'.obj"',' "',stubname,'.obj"'];
        [status,results]=system(lcc64_link);
    else
        return;
    end
end



function coderMessage=diagnoseERTSharedLibrary(results)
    coderMessage='';

    if(~isempty(strfind(results,'rtwtypes.h')))
        s=dbstack;
        callerName=s(2);
        if(~strcmp(callerName,'coder.loadlibrary'))
            coderMessage=message('MATLAB:loadlibrary:CoderLibrary','Embedded Coder Shared Library',...
            'coder.loadlibrary','loadlibrary').getString;
        end
    end
end
