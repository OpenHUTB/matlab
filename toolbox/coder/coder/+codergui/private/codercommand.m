function outputs=codercommand(varargin)





    [options,args]=parseOptions(varargin{:});

    outputs={};


    if options.typeEditor
        if numel(args)~=1

            error(message('Coder:configSet:CannotProcessOptions'));
        end
        coderTypeEditor;
        return
    end


    import matlab.internal.lang.capability.Capability;
    Capability.require([Capability.Swing,Capability.ComplexSwing]);

    error(javachk('jvm'));

    import('com.mathworks.project.impl.plugin.PluginManager');%#ok<*JAPIMATHWORKS> 
    import('com.mathworks.toolbox.coder.plugin.NewProject');
    import('com.mathworks.toolbox.coder.plugin.NewHDLCoderProject');
    import('com.mathworks.project.impl.NewOrOpenDialog');
    import('com.mathworks.project.impl.DeployTool');

    PluginManager.allowMatlabThreadUse();

    switch numel(args)
    case 0

        rejectUnusedOption('');

        if strcmp(options.objective,'gpu')
            com.mathworks.toolbox.coder.app.CoderApp.runGpuCoder();
        else
            com.mathworks.toolbox.coder.app.CoderApp.runMatlabCoder();
        end
    case 1

        rejectUnusedOption('');
        file=parseExistingFileName(args{1});
        DeployTool.invoke(file);
    case 2
        arg=args{1};
        if~ischar(arg)
            if isstring(arg)&&isscalar(arg)
                arg=char(arg);
            else
                disp(arg);
                ccdiagnosticid('Coder:configSet:CannotProcessOptions');
            end
        end
        if~coder.internal.isOptionPrefix(arg(1))||numel(arg)<2
            error(message('Coder:configSet:UnrecognizedOption',arg));
        end
        switch lower(arg(2:end))
        case 'new'

            if options.hdlcoder
                rejectUnusedOption('hdlcoder');
                file=parseNewFileName(args{2});
                NewHDLCoderProject.invoke(file);
            else
                file=parseNewFileName(args{2});
                if options.has_from
                    rejectUnusedOption('from');
                    applyTemplate(file,true,true);
                    open(file);
                else
                    rejectUnusedOption('ecoder');
                    NewProject.invoke(file,options.objective,options.ecoder);
                end
            end
        case 'open'

            rejectUnusedOption('');
            file=parseExistingFileName(args{2});
            DeployTool.invoke(file);
        case 'build'

            rejectUnusedOption('');
            file=parseExistingFileName(args{2});
            codegen(file);
        case 'tocode'

            rejectUnusedOption({'script,extra'});
            projectFileName=parseExistingFileName(args{2});
            coder.internal.projectToScript(projectFileName,options.script,options.extra);
        case 'toconfig'

            rejectUnusedOption('');
            if~coder.internal.isScalarText(args{2})
                error(message('Coder:common:CliToAppInvalidToConfigArgument'));
            end
            projectFileName=parseExistingFileName(args{2});
            outputs{1}=codergui.internal.cliToApp('project2config',projectFileName);
        case 'apply'
            try
                projectFileName=parseExistingFileName(args{2});
                create=false;
            catch
                projectFileName=parseNewFileName(args{2});
                create=true;
            end
            applyTemplate(projectFileName,create,false);
        otherwise
            error(message('Coder:configSet:UnrecognizedOption',arg));
        end
    otherwise
        error(message('Coder:configSet:CannotProcessOptions'));
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

    function applyTemplate(targetFile,isCreate,isSilent)
        template=processTemplateArg(options.from);
        if isa(template,'coder.Config')
            if isCreate
                mode='create';
            else
                mode='import';
            end
            codergui.internal.cliToApp('config2project',targetFile,mode,template,...
            'Silent',isSilent);
        else
            codergui.internal.cliToApp('project2project',template,targetFile,...
            'Silent',isSilent);
        end
    end
end


function[options,args]=parseOptions(varargin)
    args=cell(1,0);
    options.ecoder=emlcprivate('hasECoder');
    options.has_ecoder=false;
    options.hdlcoder=false;
    options.has_hdlcoder=false;
    options.script=[];
    options.has_script=false;
    options.extra='';
    options.has_extra=false;
    options.objective='c';
    options.has_from=false;
    options.from=[];
    options.typeEditor=false;
    argc=1;
    nargs=nargin;
    while itHasCurrent()
        consumed=false;
        arg=itCurrent();
        if~ischar(arg)
            if isstring(arg)&&isscalar(arg)
                arg=char(arg);
            else
                unrecognizedOption();
            end
        end
        arg=strtrim(arg);
        if coder.internal.isOptionPrefix(arg(1))
            if numel(arg)<2
                unrecognizedOption();
            end
            switch arg(2:end)
            case{'new','build','open','tocode','toconfig','apply'}
                consume(arg);
                consume(itCurrent());
            case 'gpu'
                options.objective='gpu';
                itAdvance();
                consumed=true;
            case 'ecoder'
                itAdvance();
                arg=itCurrent();
                if coder.internal.isCharOrScalarString(arg)
                    if strcmpi(arg,'false')
                        options.ecoder=false;
                    elseif~strcmpi(arg,'true')
                        n=str2double(arg);
                        if n==0
                            options.ecoder=false;
                        elseif n~=1
                            unrecognizedOption();
                        end
                    end
                elseif isnumeric(arg)&&isscalar(arg)
                    if arg==0
                        options.ecoder=false;
                    elseif arg~=1
                        unrecognizedOption();
                    end
                elseif islogical(arg)&&isscalar(arg)
                    if~arg
                        options.ecoder=false;
                    end
                else
                    unrecognizedOption();
                end
                itAdvance();
                consumed=true;
                registerOption('ecoder');
            case 'script'
                consumeCharOption('script');
            case 'from'
                consumeTemplateOption('from');
            case 'extra'
                consumeCharOption('extra');
            case 'hdlcoder'

                if strcmp(options.objective,'gpu')
                    error(message('Coder:buildProcess:invalidGpuProjectCreationArgs','-hdlcoder'));
                end

                if nargin~=3
                    error(message('Coder:buildProcess:incompleteProjectCreationArgs'));
                end
                itAdvance();
                consumed=true;
                registerOption('hdlcoder');
                options.hdlcoder=coderprivate.hasHDLCoderLicense(false,true);
                if~options.hdlcoder
                    unrecognizedOption();
                end
            case 'typeEditor'
                consume(arg);
                options.typeEditor=true;
            end
        end
        if~consumed
            consume(arg);
        end
    end

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
        if coder.internal.isCharOrScalarString(arg)
            options.(name)=char(arg);
        else
            unrecognizedOption();
        end
        itAdvance();
        consumed=true;
        registerOption(name);
    end

    function consumeTemplateOption(name)
        itAdvance();
        arg=itCurrent();
        if coder.internal.isCharOrScalarString(arg)
            options.(name)=char(arg);
        elseif isa(arg,'coder.Config')
            options.(name)=arg;
        else
            unrecognizedOption();
        end
        itAdvance();
        consumed=true;
        registerOption(name);
    end

    function unrecognizedOption()
        if coder.internal.isCharOrScalarString(arg)
            error(message('Coder:configSet:UnrecognizedOption',arg));
        else
            disp(arg);
            error(message('Coder:configSet:CannotProcessOptions'));
        end
    end
end


function file=parseExistingFileName(purportedProjectFile)
    purportedProjectFile=convertStringsToChars(purportedProjectFile);
    [pathstr,file]=parseFileName(purportedProjectFile);
    if isempty(pathstr)
        file=which(file);
    else
        file=fullfile(pathstr,file);
    end
    if~isfile(file)
        error(message('Coder:buildProcess:specifiedProjectFileNotFound',...
        purportedProjectFile))
    end

    javaFile=java.io.File(file);
    if~javaFile.isAbsolute
        file=fullfile(pwd,file);
    end
end

function file=parseNewFileName(purportedProjectFile)
    purportedProjectFile=convertStringsToChars(purportedProjectFile);
    [pathstr,file]=parseFileName(purportedProjectFile);
    if isempty(pathstr)
        file=fullfile(pwd,file);
    else
        file=fullfile(pathstr,file);
    end
    if isfile(file)
        error(message('Coder:buildProcess:specifiedProjectFileExists',...
        purportedProjectFile))
    end
end

function[pathstr,file]=parseFileName(purportedProjectFile)
    if~coder.internal.isCharOrScalarString(purportedProjectFile)
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


function template=processTemplateArg(template)
    if coder.internal.isCharOrScalarString(template)
        whichResult=which(template);
        if whichResult=="variable"
            template=evalin('caller',whichResult);
        elseif~isempty(whichResult)&&endsWith(lower(template),'.prj')
            template=parseExistingFileName(template);
            return;
        else
            template=evalin('base',template);
        end
    end
    if~isa(template,'coder.Config')
        error(message('Coder:buildProcess:invalidProjectTemplateArg'));
    end
end
