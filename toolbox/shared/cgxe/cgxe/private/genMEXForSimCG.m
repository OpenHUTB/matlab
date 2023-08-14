function status=genMEXForSimCG(modelName,moduleInfo)









    status=0;

    rebuildGateway=any([moduleInfo.newConstruction]);

    log_file_manager('begin_log');
    closeLog=onCleanup(@()log_file_manager('end_log'));









    chksumsToBuild={moduleInfo.checksums}';


    newChecksum=sync_target(modelName,chksumsToBuild);

    oldChecksum=get_checksum_from_dll(modelName);


    if(isequal(newChecksum.overall,oldChecksum.overall)&&~rebuildGateway)
        return;
    end

    rebuildAll=false;
    if~isequal(newChecksum.target,oldChecksum.target)
        rebuildAll=true;
    end

    try



        if isunix
            CGXE.Coder.errorIfNoMEXCompiler('C');
        end

        fileNameInfo=create_file_name_info(modelName,moduleInfo);


        clean_build_dir(fileNameInfo.moduleChksumStrings,fileNameInfo.targetDirName,rebuildAll);

        targetInfo=compute_compiler_info(modelName);
        [auxInfo,buildInfoUpdate]=gather_aux_Info(fileNameInfo);


        [buildInfo,auxInfo]=create_build_info(fileNameInfo,modelName,targetInfo,auxInfo);


        buildInfoUpdate(cellfun('isempty',buildInfoUpdate))=[];


        compiledauxInfoIncludes=updateBuildInfoData(buildInfo,buildInfoUpdate,modelName,fileNameInfo);

        auxInfo=addIncludesToAuxInfo(auxInfo,compiledauxInfoIncludes);




        includePaths={CGXE.Coder.getProjDir(),get_cgxe_proj(modelName,'src')};
        includePathsGroup={'USER_INCLUDES','USER_INCLUDES'};
        buildInfo.addIncludePaths(includePaths,includePathsGroup);


        incCodeGenInfo.newChecksum=newChecksum;
        incCodeGenInfo.makefile=true;






        auxFiles=gather_aux_Src_Files(auxInfo);
        moduleFiles=[fileNameInfo.moduleSourceFiles];
        requiredFiles=[auxFiles,moduleFiles];
        move_module_files_to_targetDir(fileNameInfo,requiredFiles);

        CGXE.Coder.code_model_header_file(fileNameInfo,modelName,buildInfo,auxInfo);
        CGXE.Coder.code_model_source_file(fileNameInfo,modelName);

        code_interface_and_support_files(fileNameInfo,incCodeGenInfo,buildInfo,...
        modelName,targetInfo);
        make_cgxe_target(fileNameInfo,modelName);
    catch exception
        log_file_manager('dump_log',0,modelName,true);
        rethrow(exception);
    end

    if(cgxe('Feature','DebugInfo')>0)
        log_file_manager('dump_log',0,modelName,false);
    end
end



function move_module_files_to_targetDir(fileNameInfo,fileNames)

    copySuccess=true;

    for n=1:numel(fileNames)
        srcPath=fullfile(fileNameInfo.cprjDirName,fileNames{n});
        destPath=fullfile(fileNameInfo.targetDirName,fileNames{n});

        copySuccess=copyfile(srcPath,destPath,'f');

        if~copySuccess
            failedFileName=fileNames{n};
            break;
        end
    end

    if(~copySuccess)
        makeException=MException(message('Simulink:cgxe:FileMoveFailed',...
        failedFileName,fileNameInfo.cprjDirName,fileNameInfo.targetDirName));
        throw(makeException);
    end
end


function[auxInfo,buildInfoUpdate]=gather_aux_Info(fileNameInfo)
    auxFileEmpty=struct('FileName',{},'FilePath',{},'Group',{});
    auxPathEmpty=struct('FilePath',{},'Group',{});
    auxInfo=struct('sourceFiles',auxFileEmpty,...
    'includeFiles',auxFileEmpty,...
    'includePaths',auxPathEmpty,...
    'linkObjects',auxFileEmpty,...
    'linkFlags',auxFileEmpty,...
    'codingOpenMP',[],...
    'codingSIMD','');

    buildInfoUpdate={};

    fn=fieldnames(auxInfo);
    moduleInfoFilePath=cellfun(@(n)fullfile(fileNameInfo.cprjDirName,['m_',n,'.mat']),...
    fileNameInfo.moduleUniqNames,'UniformOutput',false);

    for j=1:numel(moduleInfoFilePath)
        savedVarStruct=load(moduleInfoFilePath{j},'auxInfo','buildInfoUpdate');
        buildInfoUpdate{j}=savedVarStruct.buildInfoUpdate;%#ok

        emptyFields=structfun(@isempty,savedVarStruct.auxInfo);
        if all(emptyFields)
            continue;
        end
        fnNeedUpate=fn(~emptyFields);
        for n=1:numel(fnNeedUpate)
            auxInfo.(fnNeedUpate{n})=[auxInfo.(fnNeedUpate{n})...
            ,savedVarStruct.auxInfo.(fnNeedUpate{n})];
        end
    end

    auxInfo.codingOpenMP=any(auxInfo.codingOpenMP);



    if contains(auxInfo.codingSIMD,'AVX512')
        auxInfo.codingSIMD='AVX512';
    elseif contains(auxInfo.codingSIMD,'AVX2')
        auxInfo.codingSIMD='AVX2';
    elseif contains(auxInfo.codingSIMD,'SSE2')
        auxInfo.codingSIMD='SSE2';
    else
        auxInfo.codingSIMD='';
    end
end


function auxFiles=gather_aux_Src_Files(auxInfo)
    auxFiles={auxInfo.sourceFiles.FileName};
    auxFiles=unique(auxFiles);
end



function compiledauxInfoIncludes=updateBuildInfoData(buildInfo,buildInfoData,modelName,fileNameInfo)
    thirdPartyUses={};
    compiledauxInfoIncludes={};
    for i=1:numel(buildInfoData)
        moduleBIData=buildInfoData{i};
        if~isempty(moduleBIData)


            compiledauxInfoIncludesForBIData=modify_buildInfo_for_coder(buildInfo,moduleBIData{1});
            compiledauxInfoIncludes=[compiledauxInfoIncludes,compiledauxInfoIncludesForBIData];%#ok<AGROW>


            thirdPartyUses=[thirdPartyUses,moduleBIData{2}];%#ok<AGROW>



            updateBuildInfoArgs=moduleBIData{3};
            modify_buildInfo_for_coder(buildInfo,updateBuildInfoArgs);
        end
    end

    thirdPartyUses=unique(thirdPartyUses);
    modify_build_info_for_buildables(buildInfo,modelName,thirdPartyUses,'sfun',[],fileNameInfo.targetDirName);
end


