function ssc_buildimpl(varargin)







    s=warning('off','backtrace');
    C=onCleanup(@()warning(s));
    originalDir=pwd;
    buildDir=pwd;
    outputDirectory=pwd;


    if nargin<2
        [buildDir,libName]=ssc_screeninput('ssc_build',varargin{:});
        cd(buildDir);
        BuildDirCleanup=onCleanup(@()cd(originalDir));
        mdlName=[libName,'_lib'];
        outputDirectory=buildDir;
    else


        libName=varargin{1};
        mdlName=[libName,'_lib'];
        if contains(buildDir,'+')
            error(message(...
            'physmod:simscape:simscape:ssc_build:InvalidArgumentsInsidePackage',...
            libName));
        end
        ssc_validate_package('ssc_build',libName,buildDir);


        [maybeName,maybeDir]=lValidateOutputLibrary(varargin{2:end});
        if~ismissing(maybeName)
            mdlName=char(maybeName);
        end
        if~ismissing(maybeDir)
            outputDirectory=char(maybeDir);
        end

    end

    try
        warnstat=warning('query','all');
        warning('off','MATLAB:DELETE:FileNotFound');
        warning('off','MATLAB:DELETE:Permission');

        if nargin>1
            disp(pm_message('physmod:simscape:simscape:ssc_build:GeneratingLibInTargetDir',...
            mdlName,outputDirectory));
        elseif strcmp(originalDir,buildDir)
            disp(pm_message('physmod:simscape:simscape:ssc_build:GeneratingLibInCurrentDir',...
            mdlName,buildDir));
        else
            disp(pm_message('physmod:simscape:simscape:ssc_build:GeneratingLib',mdlName,buildDir));
        end


        isInternalPackage=ne_private('ne_isinternalpackage');
        if isInternalPackage(buildDir,libName)
            pm_error('physmod:simscape:simscape:ssc_build:InternalPackage',libName);
        end

        buildFcn=@lBuild;
        buildFcn(['+',libName],mdlName,outputDirectory);
        warning(warnstat);
    catch e
        warning(warnstat);
        isModelLoaded=bdIsLoaded(mdlName);
        if isModelLoaded
            close_system(mdlName,0);
        end


        if strcmp(e.identifier,'physmod:network_engine:ne_buildpackage:EmptyPackage')
            pm_warning('physmod:simscape:simscape:ssc_build:EmptyPackage',mdlName,libName);
        else

            newException=pm_exception('physmod:simscape:simscape:ssc_build:FailedToGenerateLib',mdlName);

            newException=addCause(newException,e);
            throwAsCaller(newException);
        end
    end
end

function lBuild(pkg,mdlName,outputDirectory)





    lValidateRunningModels();

    pm_clear;


    map=struct('m',@pcode,'ssc',@ssc_protect);
    treatMissingAsOutOfDate=false;
    forceUpdate=false;
    protectPackage=ne_private('ne_protectpackage');
    protectPackage(pkg,map,treatMissingAsOutOfDate,forceUpdate)


    buildPackage=ne_private('ne_buildpackage');
    buildPackage(pkg);

    warnstat=warning;
    warning('off','physmod:simscape:compiler:core:setup:ThroughDeprecated');
    warning('off','simscate:compiler:core:setup:AcorssDeprecated');

    buildSimulinkLibrary=nesl_private('nesl_buildpackage');
    buildSimulinkLibrary(pkg,mdlName,outputDirectory);
    warning(warnstat);

end

function lValidateRunningModels()


    openMdls=find_system('type','block_diagram');
    runningMdlsIndex=cellfun(@pmsl_ismodelrunning,openMdls);
    if any(runningMdlsIndex)
        runningMdls=openMdls(runningMdlsIndex);
        runningMdlsStr='';
        for idx=1:numel(runningMdls)
            runningMdlsStr=sprintf('%s''%s''\n',runningMdlsStr,runningMdls{idx});
        end
        pm_error('physmod:simscape:simscape:ssc_build:ModelsRunning',runningMdlsStr);
    end

end

function[mdlName,outputDirectory]=lValidateOutputLibrary(varargin)
    if nargin~=2
        exe=MException(message(...
        'physmod:simscape:simscape:ssc_build:InvalidOptions'));
        exe.throw();
    end

    if~startsWith('-output',lower(pm_charvector(varargin{1})))
        exe=MException(message(...
        'physmod:simscape:simscape:ssc_build:UnknownOption'));
        exe.throw();
    end

    outputLibrary=varargin{2};


    try
        outputLibrary=pm_charvector(outputLibrary);
    catch ME
        exe=MException(message(...
        'physmod:simscape:simscape:ssc_build:InvalidOutputLibraryArgument'));
        exe=exe.addCause(ME);
        exe.throw();
    end


    [outputDirectory,mdlName,ext]=fileparts(outputLibrary);
    if~isempty(ext)&&~(strcmp(ext,'.slx'))
        error(message('physmod:simscape:simscape:ssc_build:InvalidLibraryExtension',...
        outputLibrary));
    end

    if isempty(outputDirectory)
        outputDirectory=missing;
    elseif~isfolder(outputDirectory)
        error(message('physmod:simscape:simscape:ssc_build:InvalidOutputDir',...
        outputLibrary));
    end

    if isempty(mdlName)
        error(message('physmod:simscape:simscape:ssc_build:InvalidLibraryName',...
        outputLibrary));
    end

    mdlName=string(mdlName);
    outputDirectory=string(outputDirectory);
end





