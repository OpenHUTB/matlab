












function saveReproSteps(client,varargin)
    [isOn,bbDir]=coder.internal.bb();
    if~isOn
        return;
    end

    savefolder=coder.internal.getNextSubDir(bbDir);
    mkdir(savefolder);
    matfile=fullfile(savefolder,'args.mat');
    doit=fullfile(savefolder,'doit.m');
    pathfile=fullfile(savefolder,'path.txt');


    lf=fopen(fullfile(bbDir,'bb.log'),'a+t');
    closelog=onCleanup(@()fclose(lf));




    function print(varargin)
        fprintf(varargin{:});
        fprintf(lf,varargin{:});
    end

    print('****\n');
    print('* Starting %s in %s\n',client,pwd);






    if~startsWith(pwd,matlabroot)
        try
            copyfile('*',savefolder);
        catch

        end
    end

    x=removeAbsolutePathToPWD(varargin);
    globals=getGlobalsSnapshot();
    if isempty(globals)
        save(matfile,'x');
    else
        save(matfile,'x','globals');
    end

    pf=fopen(pathfile,'w');
    fprintf(pf,'%s',path);
    fclose(pf);

    df=fopen(doit,'w');
    fprintf(df,'function doit()\n');
    fprintf(df,'    oldv = coder.internal.bb();\n');
    fprintf(df,'    coder.internal.bb(false);\n');
    fprintf(df,'    x = load(''%s'');\n',matfile);
    fprintf(df,'    oldp = path;\n');
    fprintf(df,'    newpath = ''%s'';\n',path);
    fprintf(df,'    curfolder = ''%s'';\n',pwd);
    fprintf(df,'    path(newpath, curfolder);\n');
    fprintf(df,'    cleanPath = onCleanup(@()path(oldp));\n');
    fprintf(df,'    cleanBb = onCleanup(@()coder.internal.bb(oldv));\n');








    if~isempty(globals)
        globalVars=fieldnames(globals);
        fprintf(df,'    cleanGlobals = onCleanup(@()clearvars(''-global'', ''%s''));\n',strjoin(globalVars,''', '''));
        fprintf(df,'    global %s;\n',strjoin(globalVars,' '));
        for idx=1:numel(globalVars)
            fprintf(df,'    %s = x.globals.%s;\n',globalVars{idx},globalVars{idx});
        end
    end
    fprintf(df,'    emlcprivate(''emlckernel'', ''%s'', x.x{:});\n',client);
    fprintf(df,'end\n');
    fclose(df);

    print('* Reproduction steps saved in folder %s\n',savefolder);
    print('** Arguments are saved to %s\n',matfile);
    print('** MATLAB path is saved to %s\n',pathfile);
    print('** Doit script saved to %s\n',doit);
    print('*\n');
    print('* <a href="matlab: cd(''%s'')">cd to savefolder</a>\n',savefolder);
    print('* <a href="matlab: doit">run doit.m</a>\n');
    print('****\n');
    print('\n');
end

function args=removeAbsolutePathToPWD(args)
    for i=1:numel(args)
        args{i}=removeAbsolutePathToPWD_impl(args{i});
    end
end

function arg=removeAbsolutePathToPWD_impl(arg)
    if ischar(arg)&&startsWith(arg,pwd)
        arg=arg((numel(pwd)+2):end);
    end
end

function globals=getGlobalsSnapshot()

    globalVars=who('global');
    globalVars(strcmp(globalVars,'sfDB'))=[];
    if isempty(globalVars)
        globals=[];
        return;
    end


    evalc(['global ',strjoin(globalVars,' ')]);
    for idx=1:numel(globalVars)
        [~,globals.(globalVars{idx})]=evalc(globalVars{idx});
    end
end
