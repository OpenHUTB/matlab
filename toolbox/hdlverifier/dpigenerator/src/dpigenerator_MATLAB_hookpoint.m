function dpigenerator_MATLAB_hookpoint(projectName,buildInfo)




    if~(builtin('license','checkout','EDA_Simulator_Link'))
        error(message('HDLLink:DPIG:UnableToCheckOutLicense'));
    end


    SrcPath=emlcprivate('emcGetBuildDirectory',buildInfo,coder.internal.BuildMode.Normal);
    cd(SrcPath);


    moduleName=[projectName,'_dpi'];



    dpig_codeinfo=dpigenerator_MATLAB_getcodeinfo(projectName);


    dpigenerator_MATLAB_generateCWrapper(moduleName,dpig_codeinfo,buildInfo);






    CodeGenObj=dpig.internal.GetSVFcn_ML(dpig_codeinfo);

    modulePkgName=[moduleName,dpig.internal.GetSVFcn.getPackageFileSuffix()];
    addNonBuildFiles(buildInfo,fullfile(pwd,[modulePkgName,'.sv']));
    addNonBuildFiles(buildInfo,fullfile(pwd,[moduleName,'.sv']));

    dpigenerator_generateSVPackage(modulePkgName,...
    CodeGenObj,0);

    dpigenerator_generateSVComponent(moduleName,CodeGenObj)

    ConfigObj=MATLAB_DPICGen.DPICGenInst.configObj;

    if(strcmp(computer,'PCWIN')||strcmp(computer,'PCWIN64'))&&(~isempty(strfind(ConfigObj.Toolchain,'64-bit Linux')))


        Porting=true;

        ConfigObj.HardwareImplementation.TargetBitPerChar=8;
        ConfigObj.HardwareImplementation.TargetBitPerShort=16;
        ConfigObj.HardwareImplementation.TargetBitPerInt=32;
        ConfigObj.HardwareImplementation.TargetBitPerLong=64;
        ConfigObj.HardwareImplementation.TargetBitPerLongLong=64;
        ConfigObj.HardwareImplementation.TargetWordSize=64;
        ConfigObj.HardwareImplementation.TargetBitPerPointer=64;
        ConfigObj.HardwareImplementation.TargetBitPerSizeT=64;
        ConfigObj.HardwareImplementation.TargetBitPerPtrDiffT=64;

    else
        Porting=false;
    end




    if contains(ConfigObj.Toolchain,'Mentor Graphics QuestaSim/Modelsim')||...
        contains(ConfigObj.Toolchain,'Cadence Xcelium')
        if strcmp(computer,'PCWIN')&&contains(ConfigObj.Toolchain,'64-bit Windows')

            throw(MException(message('HDLLink:DPIG:MLOSBitCheck',32,64)));
        elseif strcmp(computer,'PCWIN64')&&contains(ConfigObj.Toolchain,'32-bit Windows')||contains(ConfigObj.Toolchain,'32-bit Linux')

            throw(MException(message('HDLLink:DPIG:MLOSBitCheck',64,32)));
        end
    end


    if~isempty(strfind(ConfigObj.Toolchain,'QuestaSim/Modelsim'))
        buildInfo.updateFilePathsAndExtensions;
        genVsimScript=dpig.internal.GenQuestaSimScript(projectName,buildInfo,Porting,...
        ConfigObj.BuildConfiguration,...
        ConfigObj.CustomToolchainOptions);
        genVsimScript.doIt;
    elseif~isempty(strfind(ConfigObj.Toolchain,'Xcelium (64-bit Linux)'))
        buildInfo.updateFilePathsAndExtensions;
        genXcelScript=dpig.internal.GenXceliumScript(projectName,buildInfo,...
        ConfigObj.BuildConfiguration,...
        ConfigObj.CustomToolchainOptions,...
        false,Porting);
        genXcelScript.doIt;
    else

        dpigenerator_disp(['Generating makefiles for: ',moduleName]);
    end


    p=MATLAB_DPICGen.DPICGenInst;


    p.SrcPath=SrcPath;
    p.moduleName=projectName;
    p.dpig_codeinfo=dpig_codeinfo;
    p.buildInfo=buildInfo;
    TestBenchGiven=p.testBench;
    DLLOutputName=p.dllOutputName;

    if TestBenchGiven
        moduleName=MATLAB_DPICGen.DPICGenInst.moduleName;
        tbModuleName=MATLAB_DPICGen.DPICGenInst.tbModuleName;
        dpig_codeinfo=MATLAB_DPICGen.DPICGenInst.dpig_codeinfo;
        dpig_codeinfo.BuildName=DLLOutputName;
        buildInfo=MATLAB_DPICGen.DPICGenInst.buildInfo;
        configObj=MATLAB_DPICGen.DPICGenInst.configObj;

        dpigenerator_generateTestBench([moduleName,'_dpi'],tbModuleName,dpig_codeinfo,buildInfo,configObj);
    end


    if~isempty(strfind(ConfigObj.Toolchain,'QuestaSim/Modelsim'))
        addNonBuildFiles(buildInfo,fullfile(pwd,[projectName,'.do']));
    elseif~isempty(strfind(ConfigObj.Toolchain,'Xcelium (64-bit Linux)'))
        addNonBuildFiles(buildInfo,fullfile(pwd,[projectName,'.sh']));
    end


    IsHDLSimulatorToolChain=~isempty(strfind(ConfigObj.Toolchain,'QuestaSim/Modelsim'))||...
    ~isempty(strfind(ConfigObj.Toolchain,'Xcelium'));

    if isempty(MATLAB_DPICGen.DPICGenInst.GenCodeOnly)&&~IsHDLSimulatorToolChain
        dpigenerator_disp('Compiling the DPI Component');
    end





end