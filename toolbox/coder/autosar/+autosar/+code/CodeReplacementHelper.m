classdef CodeReplacementHelper<handle




    methods(Static,Access=public)

        function doTypeReplacement(modelName,appTypeNamesUsedByModel,modeGroupNamesUsedByModel,...
            lAnchorFolder,lModelReferenceTargetType)



            import autosar.code.CodeReplacementHelper;

            isStandaloneBuild=strcmp(lModelReferenceTargetType,'NONE');
            if isStandaloneBuild

                CodeReplacementHelper.replaceRTWTypesWithPlatformTypes(modelName,lAnchorFolder,lModelReferenceTargetType);



                CodeReplacementHelper.replaceAppTypesWithImpTypes(modelName,appTypeNamesUsedByModel,...
                modeGroupNamesUsedByModel,lAnchorFolder,lModelReferenceTargetType);


                CodeReplacementHelper.replaceInternalTriggerCallSites(modelName,lAnchorFolder,lModelReferenceTargetType);
            else

                assert(strcmp(lModelReferenceTargetType,'RTW'),...
                'Must be a model reference RTW target build.');
                CodeReplacementHelper.replaceRTWTypesWithPlatformTypes(modelName,lAnchorFolder,lModelReferenceTargetType);
            end
        end

        function updateAraDataTypeHeaderPaths(modelName,lAnchorFolder,headerFileNames,headerFileNamesWithNamespacePath)




            import autosar.code.CodeReplacementHelper;

            originalIncludes=...
            cellfun(@(x)['#include "',x,'"'],headerFileNames,...
            'UniformOutput',false);

            includesWithNamespace=...
            cellfun(@(x)['#include "',x,'"'],headerFileNamesWithNamespacePath,...
            'UniformOutput',false);

            replacementType='String';
            lModelReferenceTargetType='NONE';
            CodeReplacementHelper.do_replacement_all(modelName,...
            originalIncludes,includesWithNamespace,...
            replacementType,lAnchorFolder,lModelReferenceTargetType);
        end
    end

    methods(Static,Access=private)

        function replaceRTWTypesWithPlatformTypes(modelName,lAnchorFolder,lModelReferenceTargetType)
            import autosar.code.CodeReplacementHelper;
            if Simulink.CodeMapping.isAutosarAdaptiveSTF(modelName)

                return
            end




            if~autosar.code.Utils.shouldReplaceRTWTypesWithARTypes(modelName)
                MSLDiagnostic('autosarstandard:code:InconsistentDataTypeReplacement',...
                modelName).reportAsWarning;
                return;
            end




            builtInTypeMap=autosar.mm.util.BuiltInTypeMapper.getRTWToPlatformTypeMap(modelName);
            findWithStr=builtInTypeMap.keys;
            replaceWithStr=builtInTypeMap.values;
            CodeReplacementHelper.do_replacement_all(modelName,findWithStr,replaceWithStr,'Type',...
            lAnchorFolder,lModelReferenceTargetType);
        end

        function replaceAppTypesWithImpTypes(modelName,appTypeNamesUsedByModel,...
            modeGroupNamesUsedByModel,lAnchorFolder,lModelReferenceTargetType)
            import autosar.code.CodeReplacementHelper;
            assert(autosar.api.Utils.isMapped(modelName),...
            'model %s is not mapped to AUTOSAR component!',modelName);



            dtMap=[];
            [app2ImpMap,modeRteCallMap,mode2ImpMap]=autosar.api.Utils.app2ImpMap(modelName);
            for appNames=app2ImpMap.keys
                if any(strcmp(appNames{1},appTypeNamesUsedByModel))
                    data=struct('ApplicationTypeName',appNames{1},...
                    'ImplementationTypeName',app2ImpMap(appNames{1}));
                    dtMap=[dtMap;data];%#ok<AGROW>
                end
            end

            if isempty(dtMap)&&modeRteCallMap.Count==0&&mode2ImpMap.Count==0
                return;
            end


            findWithStr={};
            replaceWithStr={};
            for i=1:length(dtMap)
                if~strcmp(dtMap(i).ImplementationTypeName,dtMap(i).ApplicationTypeName)
                    replaceWithStr{end+1}=dtMap(i).ImplementationTypeName;%#ok
                    findWithStr{end+1}=dtMap(i).ApplicationTypeName;%#ok
                end
            end

            for modeGrpNames=mode2ImpMap.keys
                if any(strcmp(modeGrpNames{1},modeGroupNamesUsedByModel))
                    replaceStr=mode2ImpMap(modeGrpNames{1});
                    findStr=modeGrpNames{1};
                    if~strcmp(findStr,replaceStr)
                        replaceWithStr{end+1}=replaceStr;%#ok<AGROW>
                        findWithStr{end+1}=findStr;%#ok<AGROW>
                    end
                end
            end


            CodeReplacementHelper.do_replacement_all(modelName,findWithStr,replaceWithStr,'Type',...
            lAnchorFolder,lModelReferenceTargetType);


            findWithStr={};
            replaceWithStr={};
            for modeNames=modeRteCallMap.keys
                replaceWithStr{end+1}=modeRteCallMap(modeNames{1});%#ok<AGROW>
                findWithStr{end+1}=modeNames{1};%#ok<AGROW>
            end


            CodeReplacementHelper.do_replacement_all(modelName,findWithStr,replaceWithStr,'Literal',...
            lAnchorFolder,lModelReferenceTargetType);
        end

        function replaceInternalTriggerCallSites(modelName,lAnchorFolder,lModelReferenceTargetType)

            import autosar.code.CodeReplacementHelper;

            findWithStr={'Rte_Call___'};
            replaceWithStr={'Rte_IrTrigger_'};
            CodeReplacementHelper.do_replacement_all(modelName,findWithStr,replaceWithStr,'String',...
            lAnchorFolder,lModelReferenceTargetType);
        end

        function do_replacement_all(modelName,findWithStr,replaceWithStr,replacementType,...
            lAnchorFolder,lModelReferenceTargetType)

            import autosar.code.CodeReplacementHelper;

            CodeReplacementHelper.do_replacement(modelName,findWithStr,replaceWithStr,'',replacementType);


            currentDir=pwd;

            minfoName=coder.internal.infoMATFileMgr(...
            'getMatFileName','minfo',modelName,...
            lModelReferenceTargetType);

            bDir=RTW.getBuildDir(modelName);
            sharedUtils=fullfile(lAnchorFolder,...
            bDir.SharedUtilsTgtDir);
            utilsDir=RTW.reduceRelativePath(sharedUtils);
            cd(utilsDir);
            CodeReplacementHelper.do_replacement(modelName,findWithStr,replaceWithStr,minfoName,replacementType);
            cd(currentDir);



            stubDir=fullfile(currentDir,'stub');
            if exist(stubDir,'dir')
                cd(stubDir)
                CodeReplacementHelper.do_replacement(modelName,findWithStr,replaceWithStr,'',replacementType);
                cd(currentDir);
            end
        end

        function do_replacement(modelName,findWithStr,replaceWithStr,minfoName,replacementType)








            import autosar.code.CodeReplacementHelper;

            if strcmp(get_param(modelName,'TargetLang'),'C++')
                tLang='cpp';
            else
                tLang='c';
            end
            cFiles=dir(['*.',tLang]);
            hFiles=dir('*.h');
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
                        CodeReplacementHelper.replaceViaRegexp(repFiles{i},findWithStr,replaceWithStr,replacementType);
                    catch e
                        DAStudio.error('RTW:mpt:ReplacementPerlErr',e.message);
                    end
                end
            else

                for i=1:length(repFiles)
                    tmp=rtwprivate('cmpTimeFlag',minfoName,repFiles{i});



                    if(tmp==1)||(tmp==0)
                        try
                            CodeReplacementHelper.replaceViaRegexp(repFiles{i},findWithStr,replaceWithStr,replacementType);
                        catch e
                            DAStudio.error('RTW:mpt:ReplacementPerlErr',e.message);
                        end
                    end
                end
            end
        end

        function replaceViaRegexp(fileName,origStrs,replaceStrs,replacementType)


            fileString=fileread(fileName);
            fid=fopen(fileName);
            [~,~,~,encoding]=fopen(fid);
            fclose(fid);




            if~isempty(regexp(fileString,'#define\s+__MW_INSTRUM_RECORD_HIT\(\s*id\s*\)','start'))
                return
            end

            switch(replacementType)
            case 'Type'



                patPrefix='(?<![\."/]|->)\<';
                patSuffix='(?![\."])\>';
            case 'Literal'


                patPrefix='\<';
                patSuffix='(?![\."])\>';
            case 'String'

                patPrefix='';
                patSuffix='';
            otherwise
                assert(false,'Unexpected replacementType: %s',replacementType);
            end


            for idx=1:length(origStrs)
                pat=[patPrefix,origStrs{idx},patSuffix];
                fileString=regexprep(fileString,pat,replaceStrs{idx});
            end


            fid=fopen(fileName,'w','n',encoding);
            fprintf(fid,'%s',fileString);
            fclose(fid);
        end

    end
end



