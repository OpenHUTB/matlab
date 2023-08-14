




function migrateToSharedDictionary(ddName,activeCS,guiEntry)
    if~coder.internal.CoderDataStaticAPI.migratedToCoderDictionary(ddName)

        Simulink.CodeMapping.migrateDictionary(ddName,activeCS,guiEntry);

        swct=coder.internal.CoderDataStaticAPI.getSWCT(ddName);
        Simulink.CodeMapping.createSharedUtilsMappingAndDataIfNecessary(activeCS,ddName,true,swct);
    else



        memsecPkg=get_param(activeCS,'MemSecPackage');
        hlp=coder.internal.CoderDataStaticAPI.getHelper;
        cdefs=hlp.openDD(ddName);
        pkgs=coderdictionary.data.api.getNonBuiltinPackageNames(cdefs.owner);
        if~isequal(memsecPkg,'--- None ---')&&~ismember(memsecPkg,pkgs)




            cdict=coder.dictionary.open(ddName);
            cdict.loadPackage(memsecPkg);
        end

        isCompatible=true;
        categoryMap=coder.internal.CoderDataStaticAPI.Utils.createMigrationMap();
        keyList=keys(categoryMap);
        swcEntry=coder.internal.CoderDataStaticAPI.getSWCT(cdefs);
        for i=1:length(keyList)
            aKey=keyList{i};
            csMapping=get_param(activeCS,aKey);
            if~strcmp(csMapping,'Default')
                msEntry=hlp.findEntry(cdefs,'MemorySection',[memsecPkg,'_',csMapping]);
                if isempty(msEntry)
                    isCompatible=false;
                    break;
                end
            end
            swctCategory=categoryMap(aKey);
            for j=1:length(swctCategory)
                catEntry=hlp.getProp(swcEntry,swctCategory{j});
                if~isempty(catEntry)
                    if strcmp(csMapping,'Default')


                        if~isempty(catEntry.InitialMemorySection)
                            isCompatible=false;
                            break;
                        end
                    else


                        if~isempty(catEntry.InitialMemorySection)&&...
                            catEntry.InitialMemorySection~=msEntry
                            isCompatible=false;
                            break;
                        end
                    end
                end
            end
            if~isCompatible
                break;
            end
        end

        if isCompatible
            sharedUtilsSymbol=get_param(activeCS,'CustomSymbolStrUtil');
            fcEntry=coder.mapping.defaults.get(ddName,'SharedUtility','FunctionClass');
            if~isequal(sharedUtilsSymbol,'$N$C')

                if strcmp(fcEntry,'Default')
                    isCompatible=false;
                else
                    fcEntry=hlp.findEntry(cdefs,'FunctionClass',fcEntry);
                    if~strcmp(fcEntry.FunctionName,sharedUtilsSymbol)
                        isCompatible=false;
                    end


                    sharedUtilMemSection=get_param(activeCS,'MemSecFuncSharedUtil');
                    memSec=fcEntry.MemorySection;
                    if strcmp(sharedUtilMemSection,'Default')
                        if~isempty(memSec)
                            isCompatible=false;
                        end
                    else
                        if isempty(memSec)




                            isCompatible=false;
                        end
                    end
                end
            else
                if~strcmp(fcEntry,'Default')
                    isCompatible=false;
                end
            end
        end
        if~isCompatible
            MSLDiagnostic('SimulinkCoderApp:data:CannotMigrateToSharedCoderDictionary',activeCS.Name,ddName).reportAsWarning;
        end
    end
end
