function fixedPointConverter(varargin)
















    import matlab.internal.lang.capability.Capability;
    Capability.require([Capability.Swing,Capability.ComplexSwing]);

    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    function rejectUnusedOption(names)
        if~iscell(names)
            names={names};
        end
        fldnames=fieldnames(options);
        sentinels=strfind(fldnames,'has_');
        for i=1:numel(sentinels)
            if~isempty(sentinels{i})
                test=fldnames{i};
                if options.(test)
                    name=test(5:end);
                    used=strfind(names,name);
                    if isempty([used{:}])
                        error(message('Coder:configSet:UnusedOption',name));
                    end
                end
            end
        end
    end

    [options,args]=parseOptions(varargin{:});

    switch numel(args)
    case 0

        com.mathworks.toolbox.coder.app.CoderApp.runFixedPointConverter();
    case 2
        arg=args{1};
        if~ischar(arg)
            disp(arg);
            error(message('Coder:configSet:CannotProcessOptions'));
        end
        if~coder.internal.isOptionPrefix(arg(1))||numel(arg)<2
            error(message('Coder:configSet:UnrecognizedOption',arg));
        end
        switch lower(arg(2:end))
        case 'tocode'

            rejectUnusedOption({'script'});
            projectFileName=parseExistingFileName(args{2});
            extraCLIArgs=[];




            fifeature('EnableMultipleEntryMexFcnGenerationInFiaccel',1);
            restoreFeature=onCleanup(@()fifeature('EnableMultipleEntryMexFcnGenerationInFiaccel',0));


            client='fiaccel';
            coder.internal.projectToScript(projectFileName,options.script,extraCLIArgs,client);
        otherwise
            error(message('Coder:configSet:UnrecognizedOption',arg));
        end
    otherwise
        error(message('Coder:configSet:CannotProcessOptions'));
    end
end


function[options,args]=parseOptions(varargin)
    function a=itCurrent()
        if argc>numel(varargin)
            error(message('Coder:configSet:MissingParameterOption',arg));
        end
        a=varargin{argc};
    end
    function b=itHasCurrent()
        b=argc<=nargs;
    end

    function itAdvance()
        argc=argc+1;
    end

    function consume(arg)
        args=[args,{arg}];
        itAdvance();
        consumed=true;
    end

    function registerOption(name)
        test=['has_',name];
        if options.(test)
            error(message('Coder:configSet:DuplicateOption',name));
        end
        options.(test)=true;
    end

    function consumeCharOption(name)
        itAdvance();
        arg=itCurrent();
        if ischar(arg)
            options.(name)=arg;
        else
            unrecognizedOption();
        end
        itAdvance();
        consumed=true;
        registerOption(name);
    end

    function unrecognizedOption()
        if ischar(arg)
            error(message('Coder:configSet:UnrecognizedOption',arg));
        else
            disp(arg);
            error(message('Coder:configSet:CannotProcessOptions'));
        end
    end

    args=cell(1,0);
    options.script=[];
    options.has_script=false;
    argc=1;
    nargs=nargin;
    while itHasCurrent()
        consumed=false;
        arg=itCurrent();
        if~ischar(arg)
            unrecognizedOption();
        end
        arg=strtrim(arg);
        if coder.internal.isOptionPrefix(arg(1))
            if numel(arg)<2
                unrecognizedOption();
            end
            switch arg(2:end)
            case{'tocode'}
                consume(arg);
                consume(itCurrent());
            case 'script'
                consumeCharOption('script');
            end
        end
        if~consumed
            consume(arg);
        end
    end
end


function file=parseExistingFileName(purportedProjectFile)
    [pathstr,file]=parseFileName(purportedProjectFile);
    if isempty(pathstr)
        file=which(file);
    else
        file=fullfile(pathstr,file);
    end
    if exist(file,'file')~=2
        error(message('Coder:buildProcess:specifiedProjectFileNotFound',...
        purportedProjectFile))
    end

    javaFile=java.io.File(file);
    if~javaFile.isAbsolute
        file=fullfile(pwd,file);
    end
end


function[pathstr,file]=parseFileName(purportedProjectFile)
    if~ischar(purportedProjectFile)
        error(message('Coder:configSet:CannotProcessOptions'));
    end
    [pathstr,name,ext]=fileparts(purportedProjectFile);
    prjExt='.prj';
    if isempty(ext)
        ext=prjExt;
    elseif~strcmp(ext,prjExt)
        error(message('Coder:buildProcess:badBrojectFileExtension',prjExt,ext));
    end
    file=[name,ext];
end
