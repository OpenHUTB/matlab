function ec_employ_replacement(modelName,lAnchorFolder,lModelReferenceTargetType)







    [repTypes,slTypes]=ec_get_replacetype_mapping_list(modelName);


    slTypeStr='';
    repTypeStr='';
    for i=1:length(repTypes)
        if i~=length(repTypes)
            repTypeStr=[repTypeStr,repTypes{i},','];%#ok<AGROW>
            slTypeStr=[slTypeStr,convert_dt(slTypes{i}),','];%#ok<AGROW>
        else
            repTypeStr=[repTypeStr,repTypes{i}];%#ok<AGROW>
            slTypeStr=[slTypeStr,convert_dt(slTypes{i})];%#ok<AGROW>
        end
    end


    do_replacement(modelName,slTypeStr,repTypeStr,'');


    currentDir=pwd;

    minfoName=coder.internal.infoMATFileMgr(...
    'getMatFileName','minfo',modelName,...
    lModelReferenceTargetType);

    bDir=RTW.getBuildDir(modelName);
    utilsDir=fullfile(lAnchorFolder,bDir.SharedUtilsTgtDir);

    cd(utilsDir);
    do_replacement(modelName,slTypeStr,repTypeStr,minfoName);
    cd(currentDir);


    function do_replacement(modelName,slTypeStr,repTypeStr,minfoName)










        if strcmp(get_param(modelName,'TargetLang'),'C++')
            tLang='cpp';
        else
            tLang='c';
        end
        cFiles=dir(['*.',tLang]);
        hFiles=dir('*.h');

        if strcmpi(get_param(modelName,'GenerateGPUCode'),'CUDA')
            cFiles=[cFiles;dir('*.cu')];
            hFiles=[hFiles;dir('*.hpp')];
        end

        repFiles={};


        for i=1:length(cFiles)
            if strcmp(cFiles(i).name,[modelName,'_sf.',tLang])||...
                strcmp(cFiles(i).name,[modelName,'_capi.',tLang])
                continue;
            end
            repFiles{end+1}=cFiles(i).name;%#ok<AGROW>
        end
        for i=1:length(hFiles)
            if strcmp(hFiles(i).name,'rtwtypes.h')||...
                strcmp(hFiles(i).name,'rtwtypes_sf.h')||...
                strcmp(hFiles(i).name,[modelName,'_capi.h'])||...
                strcmp(hFiles(i).name,[modelName,'_dt.h'])
                continue;
            end
            repFiles{end+1}=hFiles(i).name;%#ok<AGROW>
        end

        if isempty(minfoName)

            for i=1:length(repFiles)
                try
                    loc_ec_replacementtypes(repFiles{i},slTypeStr,repTypeStr);
                catch e
                    DAStudio.error('RTW:mpt:ReplacementPerlErr',e.message);
                end
            end
        else

            for i=1:length(repFiles)
                tmp=rtwprivate('cmpTimeFlag',minfoName,repFiles{i});



                if(tmp==1)||(tmp==0)
                    try
                        loc_ec_replacementtypes(repFiles{i},slTypeStr,repTypeStr);
                    catch e
                        DAStudio.error('RTW:mpt:ReplacementPerlErr',e.message);
                    end
                end
            end
        end


        function type=convert_dt(dType)


            if isempty(dType)==0
                switch(dType)
                case{'single','real32_T'}
                    type='real32_T';
                case{'double','real64_T','real_T'}
                    type='real_T';
                case{'int16','int16_T'}
                    type='int16_T';
                case{'int8','int8_T'}
                    type='int8_T';
                case{'int32','int32_T'}
                    type='int32_T';
                case{'uint8','uint8_T'}
                    type='uint8_T';
                case{'uint16','uint16_T'}
                    type='uint16_T';
                case{'uint32','uint32_T'}
                    type='uint32_T';
                case{'boolean'}
                    type='boolean_T';
                case{'int'}
                    type='int_T';
                case{'uint'}
                    type='uint_T';
                case{'char'}
                    type='char_T';
                case{'uint64','uint64_T'}
                    type='uint64_T';
                case{'int64','int64_T'}
                    type='int64_T';
                otherwise
                    type=dType;
                end
            else
                type=dType;
            end

            function loc_ec_replacementtypes(repFile,slTypeStr,repTypeStr)







                rtwType=strsplit(slTypeStr,{'\s',','},'DelimiterType','RegularExpression');
                repType=strsplit(repTypeStr,{'\s',','},'DelimiterType','RegularExpression');


                fileUpdater=coder.make.internal.FileUpdater(repFile);
                updatedContent=coder.internal.replaceSymbols(fileUpdater.OriginalContent,...
                rtwType,repType);
                fileUpdater.setUpdatedContent(updatedContent);
