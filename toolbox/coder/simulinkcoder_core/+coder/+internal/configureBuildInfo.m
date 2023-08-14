function[lNeedSolverSources,lModelRefString]=...
configureBuildInfo...
    (modelName,lBuildInfo,...
    lConfigSet,...
    lExtMode,modelRefBuildFolders,modelLibNames,...
    modelNames,compileAnchorDir,varargin)





    persistent p
    if isempty(p)
        p=inputParser;

        addParameter(p,'ModelReferenceTargetType','',@ischar)
        addParameter(p,'IsSimulinkAccelerator',false,@islogical);
        addParameter(p,'RapidAcceleratorIsActive',false,@islogical);
        addParameter(p,'InfoStructRelativePathToAnchor','',@ischar);
        addParameter(p,'InfoStructLinkLibrariesFullPaths',{},@iscell);
        addParameter(p,'InfoStructIncludePaths',{},@iscell);
        addParameter(p,'InfoStructContainsNonInlinedSFcn',false,@islogical);
        addParameter(p,'InfoStructModelIncludeDirs',{},@iscell);
        addParameter(p,'InfoStructModelSourceDirs',{},@iscell);
        addParameter(p,'Solver','',@ischar);
        addParameter(p,'Tid01Eq','',@ischar);
        addParameter(p,'GenRTModel','',@ischar);
        addParameter(p,'ModelReferenceInfo','',@iscell);
        addParameter(p,'CodeFormat','',@ischar);
        addParameter(p,'ClassicInterface','');
        addParameter(p,'RSIMWithSlSolver',false);
        addParameter(p,'AllocFcn','');
        addParameter(p,'NonInlinedSFunctions','',@iscell);
        addParameter(p,'TargetLangStdTfl','ANSI_C',@ischar);
    end

    parse(p,varargin{:});

    istrContainsNonInlinedSFcn=p.Results.InfoStructContainsNonInlinedSFcn;
    istrIncludeDirs=p.Results.InfoStructModelIncludeDirs;
    istrSourceDirs=p.Results.InfoStructModelSourceDirs;
    lModelReferenceTargetType=p.Results.ModelReferenceTargetType;
    lIsSimulinkAccelerator=p.Results.IsSimulinkAccelerator;
    lRapidAcceleratorIsActive=p.Results.RapidAcceleratorIsActive;
    rtwSolver=p.Results.Solver;
    rtwTid01eq=p.Results.Tid01Eq;
    rtwGenRTModel=p.Results.GenRTModel;
    modelrefInfo=p.Results.ModelReferenceInfo;
    lCodeFormat=p.Results.CodeFormat;
    lNonInlinedSFunctions=p.Results.NonInlinedSFunctions;




    lBuildInfo.TargetPreCompLibLoc=get_param(lConfigSet,...
    'TargetPreCompLibLocation');

    lSystemTargetFile=strtrim(get_param(lConfigSet,'SystemTargetFile'));


    lNeedSolverSources=locNeedSolverSources...
    (lSystemTargetFile,p.Results.RSIMWithSlSolver);


    solverSourceFile=locGetSolverSourceFile...
    (rtwGenRTModel,rtwSolver,lCodeFormat,lNeedSolverSources);
    if~isempty(solverSourceFile)
        addSourceFiles(lBuildInfo,solverSourceFile,'','SOLVER');
    end

    if strcmp(lModelReferenceTargetType,'SIM')
        lBuildInfo.addDefines('-DMATLAB_MEX_FILE','OPTS');
    end


    if strcmp(lExtMode,'on')&&...
        ~any(strcmp(lSystemTargetFile,{'sldrt.tlc','sldrtert.tlc','rtwin.tlc','rtwinert.tlc'}))&&...
        ~strcmp(lSystemTargetFile,'idelink_grt.tlc')&&...
        ~strcmp(lSystemTargetFile,'idelink_ert.tlc')&&...
        ~strcmp(lSystemTargetFile,'realtime.tlc')&&...
        ~strcmp('on',get_param(lConfigSet,'OnTargetOneClick'))&&...
        ~lRapidAcceleratorIsActive&&...
        ((exist('qeInSbRunTests','file')&&qeInSbRunTests)||...
        (exist('qeinbat','file')&&qeinbat))





        try
            qesimcheckActive=get_param(modelName,'qesimcheckExtModeTesting');
        catch me
            if isequal(me.identifier,'Simulink:Commands:ParamUnknown')
                qesimcheckActive='off';
            else
                rethrow me
            end
        end
        if~isequal(qesimcheckActive,'on')
            lBuildInfo.addDefines('-DTMW_EXTMODE_TESTING_REQ=1','OPTS');
        end
    end


    if~isempty(modelrefInfo)
        modelrefCell{length(modelrefInfo)}='';
        for idx=1:length(modelrefInfo)
            fileName=modelrefInfo{idx}{2};
            modelrefCell{idx}=fileName;
        end
        modelrefCellUnique=RTW.unique(modelrefCell);
        lModelRefString=sprintf('%s ',modelrefCellUnique{:});
    else
        lModelRefString='';
    end

    lBuildInfo.addDefines(['CLASSIC_INTERFACE=',p.Results.ClassicInterface],'Build Args');

    lBuildInfo.addDefines(['ALLOCATIONFCN=',p.Results.AllocFcn],'Build Args');

    grtInterface=0;
    if strcmp(lCodeFormat,'Embedded-C')
        grtInterface=strcmp(get_param(lConfigSet,'GRTInterface'),'on');
    end

    if strcmp(lCodeFormat,'Embedded-C')
        if(grtInterface||...
            (~strcmp(lSystemTargetFile,'modelrefsim.tlc')&&...
            (~isempty(lNonInlinedSFunctions)||istrContainsNonInlinedSFcn)))



            opts={'-DRT','-DUSE_RTMODEL','-DERT'};
            lBuildInfo.addDefines(opts,'OPTS');
        end
    end


    lBuildInfo.addDefines(['-DTID01EQ=',rtwTid01eq],'OPTS');








    locAddCustomDefines(lBuildInfo,...
    lModelReferenceTargetType,...
    lIsSimulinkAccelerator,...
    lRapidAcceleratorIsActive,...
    lConfigSet);


    if~isempty(istrIncludeDirs)
        lBuildInfo.addIncludePaths(istrIncludeDirs,'MDLREF');
    end
    if~isempty(istrSourceDirs)
        lBuildInfo.addSourcePaths(istrSourceDirs,'MDLREF');
    end


    for ii1=1:length(modelRefBuildFolders)
        mrBuildFolder=modelRefBuildFolders{ii1};
        mdlRefPath=fullfile('$(START_DIR)',mrBuildFolder);
        mrLib=RTW.BuildInfoLinkObj(modelLibNames{ii1},mdlRefPath,1000,...
        'MDLREF_LIB');


        mrLib.ReferencedBuildInfo=coder.make.enum.ReferencedBuildInfo.Required;

        lBuildInfo.addLinkObjects(mrLib);




        childHeader=fullfile(mdlRefPath,[modelNames{ii1},'.h']);
        addIncludeFiles(lBuildInfo,childHeader);
        assert(isfile(strrep(childHeader,'$(START_DIR)',compileAnchorDir)),...
        'Child component header file must exist')
    end





    function solverSourceFile=locGetSolverSourceFile...
        (lGenRTModel,lSolver,lCodeFormat,lNeedSolverSources)

        solverSourceFile='';

        if any(strcmp(lSolver,{'FixedStepDiscrete','VariableStepDiscrete'}))
            return;
        end

        if strcmp(lGenRTModel,'"0"')&&...
            ~strcmp(lCodeFormat,'Accelerator_S-Function')&&...
lNeedSolverSources

            solverSourceFile=[lSolver,'.c'];
        end


        function lNeedSolverSources=locNeedSolverSources...
            (lSystemTargetFile,lRSIMWithSlSolver)

            lNeedSolverSources=false;

            if strcmp(lSystemTargetFile,'rsim.tlc')
                lNeedSolverSources=~lRSIMWithSlSolver;
            elseif~strcmp(lSystemTargetFile,'raccel.tlc')&&...
                ~strcmp(lSystemTargetFile,'rtwsfcn.tlc')
                lNeedSolverSources=true;
            end














            function locAddCustomDefines(lBuildInfo,lModelReferenceTargetType,...
                lIsSimulinkAccelerator,...
                lRapidAcceleratorIsActive,...
                cs)

                useSim=lIsSimulinkAccelerator||...
                lRapidAcceleratorIsActive||...
                strcmp(lModelReferenceTargetType,'SIM');

                if useSim
                    simSettings=cs.getComponent('any','Simulation Target');
                    unformattedDefs=simSettings.SimUserDefines;

                else
                    rtwSettings=cs.getComponent('any','Code Generation');
                    unformattedDefs=rtwSettings.CustomDefine;
                end

                formattedDefs=coder.internal.tokenizeCustomDefines(unformattedDefs);
                lBuildInfo.addDefines(formattedDefs,'Custom');

                return;

