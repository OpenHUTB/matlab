classdef PrebuiltCC
    properties(Constant)
        TopFolder='custom_code_prebuilt_sim_exec'
        mdlFolder='modelCC'
        arch=computer('arch')
        interfaceHeader='interface_header.h'
        executable=['sim_exec',getExt()]
        prebuildMdlDesc='model_prebuilt_CC_dependencies'
    end

    methods(Static)
        function path=getPrebuitTopFolderPath(hMdl)
            [mdlPath,~,~]=fileparts(get_param(hMdl,'FileName'));
            path=fullfile(mdlPath,SLCC.OOP.PrebuiltCC.TopFolder);
        end

        function path=getPrebuitPath(hMdl,blockId)
            path='';
            if nargin<2
                [mdlPath,~,~]=fileparts(get_param(hMdl,'FileName'));
                path=fullfile(mdlPath,...
                SLCC.OOP.PrebuiltCC.TopFolder,...
                SLCC.OOP.PrebuiltCC.mdlFolder,...
                SLCC.OOP.PrebuiltCC.arch);
            else
                assert(false,'should return blockID path.');
            end
        end

        function path=getInterfaceHeaderPath(hMdl,blockId)
            path='';
            if nargin<2
                path=fullfile(SLCC.OOP.PrebuiltCC.getPrebuitPath(hMdl),...
                SLCC.OOP.PrebuiltCC.interfaceHeader);
            else
                assert(false,'should return interface header path using blockID.');
            end
        end

        function path=getExecutablePath(hMdl,blockId)
            path='';
            if nargin<2
                path=fullfile(SLCC.OOP.PrebuiltCC.getPrebuitPath(hMdl),...
                SLCC.OOP.PrebuiltCC.executable);
            else
                assert(false,'should return executable path using blockID.');
            end
        end

        function build(hMdl)
            try
                generatePrebuiltCustomCodeDependency(hMdl);
            catch E
                buildErr=E.message;
                if~isempty(E.cause)

                    buildErr=E.cause{1}.message;
                end
                ME=MException(message('Simulink:CustomCode:PrebuildFailed',get_param(hMdl,'Name')));
                ME=addCause(ME,buildErr);
                throw(ME);
            end
        end
    end
end

function ext=getExt()
    if ispc
        ext='.exe';
    else
        ext='';
    end
end

function generatePrebuiltCustomCodeDependency(hMdl)








    generatePrebuiltDirsAndCleanUp(hMdl);


    generateInterfaceHeader(hMdl);
    exeFullPath=buildExecutableForPackageCustomCodes(hMdl);


    movefile(exeFullPath,SLCC.OOP.PrebuiltCC.getExecutablePath(hMdl));

end

function generatePrebuiltDirsAndCleanUp(hMdl)








    fullPath=SLCC.OOP.PrebuiltCC.getPrebuitPath(hMdl);
    if isfolder(fullPath)
        rmdir(fullPath,'s');
    end
    mkdir(fullPath);

end

function generateInterfaceHeader(hMdl)

    sourceFiles=internal.CodeImporter.tokenize(get_param(hMdl,'SimUserSources'));
    assert(~isempty(sourceFiles),...
    'Source file is not expected to be empty for generating interface header!');

    includePaths=internal.CodeImporter.tokenize(get_param(hMdl,'SimUserIncludeDirs'));
    defines=internal.CodeImporter.tokenize(get_param(hMdl,'SimUserDefines'));
    [libMdlPath,~,~]=fileparts(get_param(hMdl,'FileName'));

    codeInsightForGeneratingInterfaceHeader=polyspace.internal.codeinsight.CodeInsight(...
    'SourceFiles',internal.CodeImporter.Tools.convertToFullPath(sourceFiles,libMdlPath),...
    'IncludeDirs',internal.CodeImporter.Tools.convertToFullPath(includePaths,libMdlPath),...
    'Defines',defines);

    options.DoSimulinkImportCompliance=true;
    options.Lang=get_param(hMdl,'SimTargetLang');
    parseArgs=namedargs2cell(options);

    success=codeInsightForGeneratingInterfaceHeader.parse(parseArgs{:});
    if success
        success=codeInsightForGeneratingInterfaceHeader.CodeInfo.generateInterfaceHeader(...
        'CodeInsightObj',codeInsightForGeneratingInterfaceHeader,...
        'OutputFile',SLCC.OOP.PrebuiltCC.getInterfaceHeaderPath(hMdl));
    end
    if~success
        errmsg=MException(message('Simulink:CustomCode:PrebuildInterfaceHeaderUnsuccessful'));
        throw(errmsg);
    end

end

function exeFullPath=buildExecutableForPackageCustomCodes(hMdl)

    orig_desc=get_param(hMdl,'Description');
    set_param(hMdl,'Description',SLCC.OOP.PrebuiltCC.prebuildMdlDesc);


    function restoreMdlDesc(hMdl,orig_desc)
        set_param(hMdl,'Description',orig_desc);
    end
    modelDescCleaner=onCleanup(@()restoreMdlDesc(hMdl,orig_desc));

    interfaceHeaderFullPath=SLCC.OOP.PrebuiltCC.getInterfaceHeaderPath(hMdl);
    set_param(hMdl,'SimCustomHeaderCode',['#include "',interfaceHeaderFullPath,'"']);
    set_param(hMdl,'SimDebugExecutionForCustomCode','on');
    slccprivate('parseCustomCode',hMdl,true);
    slccprivate('buildCustomCodeForModel',hMdl);
    settingChecksum=slcc('getModelCustomCodeChecksum',hMdl);
    fullChecksum=slcc('getCustomCodeFullChecksum',hMdl);

    exeFileName=[fullChecksum,getExt()];
    projRootDir=cgxeprivate('get_cgxe_proj_root');
    exeFullPath=fullfile(projRootDir,'slprj/','_sloop/',settingChecksum,exeFileName);
    assert(isfile(exeFullPath),'The built custom code simulation executable must exist.');

end