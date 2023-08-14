function create(name,varargin)






    name=convertStringsToChars(name);
    if nargin>1
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    inputs=loc_parseInputs(name,varargin{:});


    loc_launchCPP(inputs);
end


function inputs=loc_parseInputs(name,varargin)
    p=inputParser;
    p.addRequired('ModelName',@loc_validateModelName);
    p.addParameter('Supports',{'ModelReferenceSimTarget'},@loc_validateModes);
    p.addParameter('Path',pwd(),@loc_validatePath);
    p.addParameter('Verbose',true,@loc_validateVerbose);
    p.addParameter('Release',Simulink.packagedmodel.getRelease(),@loc_validateRelease);
    p.addParameter('Platform',computer('arch'),@loc_validatePlatform);
    p.addParameter('VMTarget',false,@loc_validateVMTarget);
    p.addParameter('UseThreads',false,@loc_validateThreads);
    p.parse(name,varargin{:});

    inputs=p.Results;
end


function result=loc_validateModelName(x)
    if~ischar(x)
        DAStudio.error('Simulink:cache:invalidModelName');
    end

    result=true;
end


function result=loc_validateModes(x)
    supportedModes={'ModelReferenceSimTarget','RapidAccelerator',...
    'Accelerator','VarCache'};
    if~iscell(x)||~isempty(setdiff(x,supportedModes))
        DAStudio.error('Simulink:cache:invalidSupportModes');
    end
    result=true;
end


function result=loc_validatePath(x)
    if~ischar(x)
        DAStudio.error('Simulink:cache:invalidPath',x);
    end
    result=true;
end


function result=loc_validateVerbose(x)
    if~islogical(x)
        DAStudio.error('Simulink:cache:invalidVerbose',x);
    end
    result=true;
end


function result=loc_validateRelease(x)
    if~ischar(x)
        DAStudio.error('Simulink:cache:invalidRelease',x);
    end
    result=true;
end


function result=loc_validatePlatform(x)
    if~ischar(x)
        DAStudio.error('Simulink:cache:invalidPlatform',x);
    end
    result=true;
end


function result=loc_validateVMTarget(x)
    if~islogical(x)
        DAStudio.error('Simulink:cache:invalidVMTarget',x);
    end
    result=true;
end


function result=loc_validateThreads(x)
    if~islogical(x)
        DAStudio.error('Simulink:cache:invalidUseThreads',x);
    end
    result=true;
end

function loc_launchCPP(inputs)
    builtin('_removeAllSLCacheModelInfo');
    switch(inputs.Supports{1})
    case 'ModelReferenceSimTarget'
        info=builtin('_getSLCacheModelInfo',inputs.ModelName,slcache.Modes.SIM);
        info.release=inputs.Release;
        info.platform=inputs.Platform;
        info.toBePacked=true;
        info.cacheFolder=inputs.Path;
        info.compiler=Simulink.packagedmodel.getSimCompiler();
        opcInfo={};
        builtin('_packSLCacheSIM',inputs.ModelName,true,opcInfo);
    case 'Accelerator'
        info=builtin('_getSLCacheModelInfo',inputs.ModelName,slcache.Modes.ACCEL);
        info.release=inputs.Release;
        info.platform=inputs.Platform;
        info.toBePacked=true;
        info.cacheFolder=inputs.Path;
        info.isVMTarget=inputs.VMTarget;
        if~info.isVMTarget
            info.compiler=Simulink.packagedmodel.getSimCompiler();
        end
        builtin('_packSLCacheAccel',inputs.ModelName,true);
    case 'RapidAccelerator'
        info=builtin('_getSLCacheModelInfo',inputs.ModelName,slcache.Modes.RAPID);
        info.release=inputs.Release;
        info.platform=inputs.Platform;
        info.toBePacked=true;
        info.cacheFolder=inputs.Path;
        info.compiler=Simulink.packagedmodel.getSimCompiler();

        lDefaultCompInfo=coder.internal.DefaultCompInfo.createDefaultCompInfo;
        objExt=Simulink.packagedmodel.getSLXCObjectFileExtension('toolchain',lDefaultCompInfo.ToolchainInfo);
        builtin('_packSLCacheRapidAccel',inputs.ModelName,true,false,objExt);
    otherwise

    end
end


