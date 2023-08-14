function createSharedUtilsMappingAndDataIfNecessary(activeCS,source,isShared,mapping)




    sharedUtilsSymbol=get_param(activeCS,'CustomSymbolStrUtil');
    utilityFcnEntryName='UtilityFunction';
    memSecPkg=get_param(activeCS,'MemSecPackage');
    if~isequal(sharedUtilsSymbol,'$N$C')

        hlp=coder.internal.CoderDataStaticAPI.getHelper();
        dd=hlp.openDD(source);
        fcEntry=hlp.createEntry(dd,...
        'FunctionClass',utilityFcnEntryName);
        hlp.setProp(fcEntry,'FunctionName',sharedUtilsSymbol)

        if isShared


            fcnConfig=hlp.getProp(mapping,'SharedUtility');
            hlp.setProp(fcnConfig,'InitialFunctionClass',fcEntry);
        else

            modelH=get_param(mapping.getModelName(),'Handle');
            uuid=codermapping.internal.c.dictionary.getFunctionCustomizationTemplateUuidFromName(...
            modelH,utilityFcnEntryName,'SharedUtility');
            mapping.DefaultsMapping.set('SharedUtility','FunctionClass',uuid);
        end


        sharedUtilMemSection=get_param(activeCS,'MemSecFuncSharedUtil');
        if~isequal(memSecPkg,'--- None ---')&&~isequal(sharedUtilMemSection,'Default')



            fc1=hlp.findEntry(dd,'FunctionClass',utilityFcnEntryName);


            legacyMSEntry=hlp.findEntry(dd,'MemorySection',sharedUtilMemSection);
            assert(isa(legacyMSEntry,'coderdictionary.data.LegacyMemorySection'));


            msEntryName=...
            coder.internal.CoderDataStaticAPI.Utils.getUniqueEntryName(...
            dd,'MemorySection',sharedUtilMemSection);
            msEntry=hlp.createEntry(dd,'MemorySection',msEntryName);








            legacyComment=hlp.getProp(legacyMSEntry,'Comment');
            if~isempty(legacyComment)
                try
                    hlp.setProp(msEntry,'Comment',legacyComment);
                catch ME
                    MSLDiagnostic(...
                    'SimulinkCoderApp:data:MemorySectionPropertyNotCopyable',...
                    ME.message,hlp.getProp(ms1,'DisplayName')).reportAsWarning;
                end
            end
            legacyPreStatement=hlp.getProp(legacyMSEntry,'PreStatement');
            if~isempty(legacyPreStatement)
                try
                    hlp.setProp(msEntry,'PreStatement',legacyPreStatement);
                catch ME
                    MSLDiagnostic(...
                    'SimulinkCoderApp:data:MemorySectionPropertyNotCopyable',...
                    ME.message,hlp.getProp(ms1,'DisplayName')).reportAsWarning;
                end
            end
            legacyPostStatement=hlp.getProp(legacyMSEntry,'PostStatement');
            if~isempty(legacyPostStatement)
                try
                    hlp.setProp(msEntry,'PostStatement',legacyPostStatement);
                catch ME
                    MSLDiagnostic(...
                    'SimulinkCoderApp:data:MemorySectionPropertyNotCopyable',...
                    ME.message,hlp.getProp(ms1,'DisplayName')).reportAsWarning;
                end
            end
            pragmaPerVar=hlp.getProp(legacyMSEntry,'PragmaPerVar');
            if~pragmaPerVar
                try
                    hlp.setProp(msEntry,'StatementsSurround','AllVariables');
                catch ME
                    MSLDiagnostic(...
                    'SimulinkCoderApp:data:MemorySectionPropertyNotCopyable',...
                    ME.message,hlp.getProp(ms1,'DisplayName')).reportAsWarning;
                end
            end



            hlp.setProp(fc1,'MemorySection',msEntry);
        end
    else
        if isShared
            Simulink.CodeMapping.setSharedMappingMSFromCS(source,activeCS,'MemSecFuncSharedUtil','SharedUtility');
        else
            Simulink.CodeMapping.setModelMappingMSFromCS(mapping,activeCS,'MemSecFuncSharedUtil','SharedUtility');
        end
    end

end
