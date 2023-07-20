function params=processHeaderFileOrModelName(fileOrMdlName,params,paramsWithDefaults)



    isLoadedModel=isThisALoadedModel(fileOrMdlName);
    if(isLoadedModel)
        flagConflictingFields(params.Language,paramsWithDefaults);



        cs=getModelConfigSet(fileOrMdlName);%#ok<NASGU>

        projRootDir=cgxeprivate('get_cgxe_proj_root');
        customCodeSettings=cgxeprivate('get_custom_code_settings',fileOrMdlName);
        customCode=customCodeSettings.getCustomCodeFromSettings();
        params.headerFiles=customCode;
        checkForEmptyHeaderField(params.headerFiles,fileOrMdlName);

        params.Defines=customCodeSettings.customUserDefines;

        [userIncludeDirs,~,~]=cgxeprivate('getTokenizedPathsAndFiles',fileOrMdlName,...
        projRootDir,customCodeSettings,'');
        params.IncludeDirs=userIncludeDirs;







        if paramIsUnspecified(paramsWithDefaults,'OutputDir')


            params.OutputDir=projRootDir;
        end


        if customCodeSettings.isCpp
            params.Language='C++';
        else
            params.Language='C';
        end
    else


        if~iscell(fileOrMdlName)
            fileOrMdlName={fileOrMdlName};
        end
        params.headerFiles=sprintf('#include "%s"\n',fileOrMdlName{:});


        if strcmpi(params.Language,'auto')
            validExts={'.hpp','.cxx','.cpp'};
            params.Language='C';
            for i=1:numel(fileOrMdlName)
                [~,~,ext]=fileparts(fileOrMdlName{i});
                if any(strcmpi(ext,validExts))
                    params.Language='C++';
                    break;
                end
            end
        end
    end
end

function retVal=isThisALoadedModel(fileOrMdlName)
    retVal=false;
    if~iscell(fileOrMdlName)
        try
            retVal=bdIsLoaded(fileOrMdlName);
        catch
        end
    end
end

function cs=getModelConfigSet(modelName)
    cs=[];
    try
        cs=getActiveConfigSet(modelName);
        if~isempty(cs)
            if isa(cs,'Simulink.ConfigSetRef')
                cs=cs.getRefConfigSet;
            end
        end
    catch
    end
    if~isa(cs,'Simulink.ConfigSet')
        errorId='Simulink:CustomCode:TypeImporterModelHasNoConfigurationParameters';
        error(errorId,getString(message(errorId,modelName)));
    end
end

function hasDefaultVal=paramIsUnspecified(paramsWithDefaults,param)
    hasDefaultVal=ismember(param,paramsWithDefaults);
end

function checkForEmptyHeaderField(header,fileOrMdlName)
    header=regexprep(header,'^\s*|\s*$','');
    if isempty(header)
        warningId='Simulink:CustomCode:TypeImporterModelHeaderFieldEmpty';
        SLCC.TypeImporter.reportWarning(warningId,getString(message(warningId,fileOrMdlName)));
    end
end

function flagConflictingFields(paramsLanguage,paramsWithDefaults)
    if(~paramIsUnspecified(paramsWithDefaults,'IncludeDirs'))
        warningId='Simulink:CustomCode:TypeImporterArgumentShadowed';
        SLCC.TypeImporter.reportWarning(warningId,getString(message(warningId,"IncludeDirs")));
    end
    if(~paramIsUnspecified(paramsWithDefaults,'Defines'))
        warningId='Simulink:CustomCode:TypeImporterArgumentShadowed';
        SLCC.TypeImporter.reportWarning(warningId,getString(message(warningId,"Defines")));
    end
    if(~paramIsUnspecified(paramsWithDefaults,'HardwareImplementation'))
        warningId='Simulink:CustomCode:TypeImporterArgumentShadowed';
        SLCC.TypeImporter.reportWarning(warningId,getString(message(warningId,"HardwareImplementation")));
    end
    if(~paramIsUnspecified(paramsWithDefaults,'Language')&&~strcmpi(paramsLanguage,'auto'))
        warningId='Simulink:CustomCode:TypeImporterArgumentShadowed';
        SLCC.TypeImporter.reportWarning(warningId,getString(message(warningId,"Language")));
    end
end