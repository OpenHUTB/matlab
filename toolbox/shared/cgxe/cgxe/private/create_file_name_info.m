function fileNameInfo=create_file_name_info(modelName,moduleInfo)



    [projectDirPath,projectDirArray,projectDirRelPath,projectDirReverseRelPath]=get_cgxe_proj(modelName,'src');

    fileNameInfo.modelName=modelName;
    fileNameInfo.modelHandle=get_param(modelName,'Handle');
    fileNameInfo.targetDirName=projectDirPath;
    fileNameInfo.targetDirRelPath=projectDirRelPath;
    fileNameInfo.cprjDirName=CGXE.Coder.getProjDir();

    baseName=[modelName,'_cgxe'];
    fileNameInfo.mexFunctionName=baseName;

    create_directory_path(projectDirArray{:});

    fileNameInfo.dllDirFromMakeDir=projectDirReverseRelPath;

    [gencpp,fileNameInfo.compilerName,fileNameInfo.mexSetEnv]=get_cgxe_compiler_info(modelName);

    if gencpp
        fileNameInfo.headerExtension='.hpp';
        fileNameInfo.sourceExtension='.cpp';
    else
        fileNameInfo.headerExtension='.h';
        fileNameInfo.sourceExtension='.c';
    end

    fileNameInfo.modelRegistryFile=[baseName,'_registry',fileNameInfo.sourceExtension];
    fileNameInfo.modelHeaderFile=[baseName,fileNameInfo.headerExtension];
    fileNameInfo.modelSourceFile=[baseName,fileNameInfo.sourceExtension];

    fileNameInfo.moduleInfo=moduleInfo;
    fileNameInfo.numModules=length(moduleInfo);

    fileNameInfo.moduleChksumStrings=cell(1,fileNameInfo.numModules);
    fileNameInfo.moduleHeaderFiles=cell(1,fileNameInfo.numModules);
    fileNameInfo.moduleSourceFiles=cell(1,fileNameInfo.numModules);
    fileNameInfo.moduleUniqNames=cell(1,fileNameInfo.numModules);

    for i=1:fileNameInfo.numModules
        if~ischar(fileNameInfo.moduleInfo(i).checksums)
            fileNameInfo.moduleChksumStrings{i}=cgxe('MD5AsString',fileNameInfo.moduleInfo(i).checksums);
        else
            fileNameInfo.moduleChksumStrings{i}=fileNameInfo.moduleInfo(i).checksums;
        end

        fileNameInfo.moduleUniqNames{i}=fileNameInfo.moduleChksumStrings{i};
        fileNameInfo.moduleHeaderFiles{i}=['m_',fileNameInfo.moduleUniqNames{i},fileNameInfo.headerExtension];
        fileNameInfo.moduleSourceFiles{i}=['m_',fileNameInfo.moduleUniqNames{i},fileNameInfo.sourceExtension];
    end

    customCodeSettings=CGXE.CustomCode.CustomCodeSettings.createFromModel(modelName);
    fileNameInfo=customCodeSettings.addToFileNameInfo(fileNameInfo,modelName);


    fileNameInfo.customCodeDLL={};

    fileNameInfo.hasSLCCCustomCode=false;

    ccCheckSum=slcc('getModelCustomCodeChecksum',fileNameInfo.modelHandle,false);
    fileNameInfo.hasSLCCCustomCode=~isempty(ccCheckSum);

    libraryCCDeps=slcc('getCachedCustomCodeDependencies',fileNameInfo.modelHandle);

    for i=1:numel(libraryCCDeps)
        checkSum=libraryCCDeps(i).SettingsChecksum;
        assert(~isempty(checkSum),'Empty custom code checksum in cached custom code dependencies!');
        if~libraryCCDeps(i).IsOutOfProcessExecution&&...
            ~isempty(libraryCCDeps(i).CustomCodeLibPath)
            ccLibFullPath=CGXE.CustomCode.getCustomLibNameFromModel('','import',checkSum);
            fileNameInfo.customCodeDLL{end+1}=ccLibFullPath;
        end
    end

    fileNameInfo.matlabRoot=matlabroot;

    fileNameInfo.useBlas=cgxeCodingBlas;
    if fileNameInfo.useBlas
        fileNameInfo.stddefIncludeFile='stddef.h';
        if strcmp(computer,'PCWIN')||strcmp(computer,'PCWIN64')
            compilerName=fileNameInfo.compilerName;
            if~isempty(regexp(compilerName,'^msvc|^mssdk','once'))
                compilerName='microsoft';
            elseif strcmp(computer,'PCWIN64')&&strcmp(compilerName,'lcc')
                compilerName='microsoft';
            end
            fileNameInfo.blasLibFile=fullfile(fileNameInfo.matlabRoot,'extern','lib',computer('arch'),compilerName,'libmwblas.lib');
            if~exist(fileNameInfo.blasLibFile,'file')
                fileNameInfo.blasLibFile=[];
            end
        else
            fileNameInfo.blasLibFile='libmwblas.so';
        end
    end

    fileNameInfo.openMPIncludeFile=[];

    fileNameInfo.makeBatchFile=[modelName,'_cgxe.bat'];
    fileNameInfo.modelDefFile=[modelName,'_cgxe.def'];
    fileNameInfo.SFunctionName=[modelName,'_cgxe'];
    fileNameInfo.unixMakeFile=[modelName,'_cgxe.mku'];
    fileNameInfo.msvcdspFile=[modelName,'_cgxe.dsp'];
    fileNameInfo.msvcdswFile=[modelName,'_cgxe.dsw'];
    fileNameInfo.msvcvcprojFile=[modelName,'_cgxe.vcproj'];
    fileNameInfo.msvcMakeFile=[modelName,'_cgxe.mak'];
    fileNameInfo.borlandMakeFile=[modelName,'_cgxe.bmk'];
    fileNameInfo.lccMakeFile=[modelName,'_cgxe.lmk'];
    fileNameInfo.mingwMakeFile=[modelName,'_cgxe.gmk'];
    fileNameInfo.objListFile=[modelName,'_cgxe.mol'];
