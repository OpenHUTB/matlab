function buildOpts=createBuildOpts(varargin)





    p=inputParser;

    addParameter(p,'SystemTargetFileFullPath','');
    addParameter(p,'TMFModules',{});
    addParameter(p,'ModelrefInfo',{});
    addParameter(p,'BuildName','');
    addParameter(p,'SolverMode','');
    addParameter(p,'MemAlloc','');
    addParameter(p,'TargetLangExt','.c');
    addParameter(p,'codeWasUpToDate',false);
    addParameter(p,'generateCodeOnly',false);
    addParameter(p,'IsCpp',false);
    addParameter(p,'AutosarTopCodegenFolder','');
    addParameter(p,'AutosarTopComponent','');
    parse(p,varargin{:});


    lBuildOptModules=sprintf('%s ',p.Results.TMFModules{:});






    [~,systemTargetFilename,ext]=fileparts(p.Results.SystemTargetFileFullPath);
    systemTargetFilename=[systemTargetFilename,ext];


    buildOpts=coder.internal.HookBuildOpts...
    (p.Results.TargetLangExt,...
    p.Results.BuildName,...
    p.Results.MemAlloc,...
    systemTargetFilename,...
    p.Results.SolverMode,...
    lBuildOptModules,...
    p.Results.IsCpp,...
    p.Results.generateCodeOnly,...
    p.Results.codeWasUpToDate,...
    p.Results.ModelrefInfo,...
    p.Results.AutosarTopCodegenFolder,...
    p.Results.AutosarTopComponent);
