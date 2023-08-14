function buildHostCAPI(topModelBuildInfo)




    topModelBuildDirStruct=RTW.getBuildDir(topModelBuildInfo.ModelName);






    topc_str=local_top_c(topModelBuildInfo.ModelName);
    c_file_name=[topModelBuildInfo.ModelName,'_capi_host.c'];
    c_fid=fopen(c_file_name,'w');
    fprintf(c_fid,topc_str);
    fclose(c_fid);




    cfiles={fullfile(topModelBuildDirStruct.BuildDirectory,c_file_name)};
    cppfiles={};




    if rtwprivate('rtw_is_cpp_build',topModelBuildInfo.ModelName)
        langExt='cpp';
    else
        langExt='c';
    end





    files={fullfile(topModelBuildDirStruct.BuildDirectory,[topModelBuildInfo.ModelName,'_capi.',langExt])};

    protectedModels={};
    subModelsInProtected={};





    for i=1:length(topModelBuildInfo.ModelRefs)

        subModelBuildPath=strrep(topModelBuildInfo.ModelRefs(i).Path,...
        '$(START_DIR)',topModelBuildInfo.Settings.LocalAnchorDir);


        [~,subModelName]=fileparts(subModelBuildPath);


        files=[files;fullfile(subModelBuildPath,[subModelName,'_capi.',langExt])];%#ok



        [isProtected,~]=slInternal('getReferencedModelFileInformation',subModelName);
        if isProtected
            protectedModels{end+1}=subModelName;
            binfomdl=coder.internal.infoMATFileMgr('load','binfo',subModelName,'SIM');
            for j=1:length(binfomdl.modelRefsAll)
                subModelsInProtected{end+1}=binfomdl.modelRefsAll{j};
            end
        end

    end

    protectedModels=unique(protectedModels);
    subModelsInProtected=unique(subModelsInProtected);





    if rtwprivate('rtw_is_cpp_build',topModelBuildInfo.ModelName)
        cppfiles=[cppfiles;files];
    else
        cfiles=[cfiles;files];
    end




    mexFilePath=fullfile(topModelBuildDirStruct.BuildDirectory,'tmwinternal');
    mexFileName=[topModelBuildInfo.ModelName,'_capi_host'];

















    binfo_cache=coder.internal.infoMATFileMgr('loadNoConfigSet','binfo',...
    topModelBuildInfo.ModelName,'NONE');









    if((slfeature('ParamTuningAppSvc')==1&&binfo_cache.modelHasTunableStructParams)||...
        slfeature('ParamTuningAppSvc')==2)||...
        (~strcmp(get_param(topModelBuildInfo.ModelName,'SystemTargetFile'),'raccel.tlc'))

        try
            inc_dirs=regexprep(topModelBuildInfo.getBuildDirList,'(.*)','-I$0','once');
            if~isempty(cfiles)&&~isempty(cppfiles)



                mex('-c',...
                '-DHOST_CAPI_BUILD',...
                ['-I',fullfile(matlabroot,'rtw','c','src')],...
                inc_dirs{:},...
                cfiles{:});

                if ispc
                    objext='.obj';
                else
                    objext='.o';
                end
                cfiles=strrep(cfiles,'.c',objext);

                mex('-silent',...
                '-output',mexFileName,...
                '-outdir',mexFilePath,...
                '-DHOST_CAPI_BUILD',...
                ['-I',fullfile(matlabroot,'rtw','c','src')],...
                inc_dirs{:},...
                cfiles{:},...
                cppfiles{:});
            else





                mexForce='';
                mexLcc64='';
                if strcmp(computer,'PCWIN64')&&isempty(mex.getCompilerConfigurations('C','selected'))
                    mexForce='-f';
                    mexLcc64=fullfile(matlabroot,'rtw','c','tools','lcc-win64.xml');
                end




                for i=1:length(cfiles)

                    [~,subModelName]=fileparts(cfiles{i});


                    subModelName=strrep(subModelName,'_capi','');

                    isProtected=0;
                    isInsideProtected=0;

                    if~isempty(protectedModels)
                        isProtected=~isempty(find(strcmp(subModelName,protectedModels),1));
                    end

                    if~isempty(subModelsInProtected)
                        isInsideProtected=~isempty(find(strcmp(subModelName,subModelsInProtected),1));
                    end

                    if isProtected||isInsideProtected


                        oldString=[subModelName,'_capi.c'];
                        if ispc
                            newString=[subModelName,'_capi_host.obj'];
                        else
                            newString=[subModelName,'_capi_host.o'];
                        end
                        newcfile=strrep(cfiles{i},oldString,newString);
                        cfiles{i}=newcfile;

                        searchDir=['slprj',filesep,'sim',filesep,subModelName];



                        tempStr=inc_dirs{1};





                        delStr=['slprj',filesep,'raccel',filesep,topModelBuildInfo.ModelName];
                        newStr=strrep(tempStr,delStr,searchDir);
                        inc_dirs{i-1}=newStr;
                    end

                end
                mex(mexForce,mexLcc64,...
                '-silent',...
                '-output',mexFileName,...
                '-outdir',mexFilePath,...
                '-DHOST_CAPI_BUILD',...
                ['-I',fullfile(matlabroot,'rtw','c','src')],...
                inc_dirs{:},...
                cfiles{:});
            end
        catch exc
            errID='Connectivity:tgtconn:ErrorBuildingHostBasedCAPI';
            msg=DAStudio.message(errID,topModelBuildInfo.ModelName);
            newExc=MException(errID,'%s',msg);
            newExc=newExc.addCause(exc);
            throw(newExc);
        end
    end
end

function topc_str=local_top_c(modelName)
    if isempty(strfind(computer(),'PCWIN'))
        export_str='';
    else
        export_str='__declspec( dllexport ) ';
    end

    topc_str=[...
    '#include "',modelName,'_capi_host.h"\n'...
    ,'static ',modelName,'_host_DataMapInfo_T root;\n'...
    ,'static int initialized = 0;\n'...
    ,export_str,'rtwCAPI_ModelMappingInfo *getRootMappingInfo()\n'...
    ,'{\n'...
    ,'    if (initialized == 0) {\n'...
    ,'        initialized = 1;\n'...
    ,'        ',modelName,'_host_InitializeDataMapInfo(&(root), "',modelName,'");\n'...
    ,'    }\n'...
    ,'    return &root.mmi;\n'...
    ,'}\n'...
    ,'\n'...
    ,'rtwCAPI_ModelMappingInfo *mexFunction() {return(getRootMappingInfo());}\n'
    ];
end
