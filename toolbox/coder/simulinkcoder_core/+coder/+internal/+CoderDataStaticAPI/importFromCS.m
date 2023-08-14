function importFromCS(sourceDD,cs)












    import coder.internal.CoderDataStaticAPI.*;
    if strcmp(get_param(cs,'IsERTTarget'),'on')
        hlp=getHelper();

        [dd,loadSLPkg]=Utils.openCDefinitions(sourceDD);
        isModelDict=Utils.isModelDict(dd);
        memSecPkg=get_param(cs,'MemSecPackage');
        if strcmp(memSecPkg,'--- None ---')
            Utils.initializeDict(dd,loadSLPkg,true);
        else
            Utils.initializeDict(dd,false,true);
            coder.internal.CoderDataStaticAPI.importLegacyPackage(dd,memSecPkg);



            if~isModelDict



                memSecPkg=get_param(cs,'MemSecPackage');
                if strcmp(memSecPkg,'--- None ---')
                    return;
                end
                categoryMap=Utils.createMigrationMap();
                keyList=keys(categoryMap);
                swcEntry=coder.internal.CoderDataStaticAPI.getSWCT(dd);
                for i=1:length(keyList)
                    aKey=keyList{i};
                    csMapping=get_param(cs,aKey);
                    if strcmp(csMapping,'Default')
                        continue;
                    end
                    msEntry=hlp.findEntry(dd,'MemorySection',[memSecPkg,'_',csMapping]);
                    if isempty(msEntry)
                        DAStudio.error('coderdictionary:mapping:LegacyMemorySectionNotFound',csMapping,memSecPkg);
                    end

                    swctCategory=categoryMap(aKey);
                    for j=1:length(swctCategory)
                        catEntry=hlp.getProp(swcEntry,swctCategory{j});
                        if~isempty(catEntry)
                            hlp.setProp(catEntry,'InitialMemorySection',msEntry);
                        end
                    end
                end
            end
        end
    end
end
