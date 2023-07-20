function replaceCDictRefWithCopy(mdl)







    sr=slroot;
    if sr.isValidSlObject(mdl)
        mdlH=get_param(mdl,'handle');
        hlp=coder.internal.CoderDataStaticAPI.getHelper;
        needLocal=true;
        dd=hlp.openDD(mdlH,'C',needLocal);
        cm=coder.internal.CoderDataStaticAPI.CacheManager;
        refs=cell(1,dd.owner.ReferencedContainers.Size);
        for i=1:dd.owner.ReferencedContainers.Size
            refs{i}=dd.owner.ReferencedContainers(i).Name;
        end

        dd.owner.replaceReferencedContainers();
        uuidMap=containers.Map;
        for i=1:length(refs)
            src=cm.getPackageCache(refs{i});
            for j=1:src.CDefinitions.StorageClasses.Size
                srcEntry=src.CDefinitions.StorageClasses(j);
                uuidMap(srcEntry.UUID)=dd.findEntry('StorageClass',srcEntry.Name).UUID;
            end
            for j=1:src.CDefinitions.MemorySections.Size
                srcEntry=src.CDefinitions.MemorySections(j);
                uuidMap(srcEntry.UUID)=dd.findEntry('MemorySection',srcEntry.Name).UUID;
            end
        end

        mapping=Simulink.CodeMapping.get(mdl,'CoderDictionary');
        if~isempty(mapping)
            categories=coder.mapping.internal.dataCategories;
            for i=1:numel(categories)
                category=categories{i};
                propName=mapping.DefaultsMapping.getPropNameFromType(category);
                srcProp=mapping.DefaultsMapping.(propName);
                if~isempty(srcProp.MemorySection)&&~isempty(srcProp.MemorySection.UUID)
                    if uuidMap.isKey(srcProp.MemorySection.UUID)
                        mapping.DefaultsMapping.set(category,'MemorySection',uuidMap(srcProp.MemorySection.UUID));
                    end
                end
                if~isempty(srcProp.StorageClass)&&~isempty(srcProp.StorageClass.UUID)
                    if uuidMap.isKey(srcProp.StorageClass.UUID)
                        mapping.DefaultsMapping.set(category,'StorageClass',uuidMap(srcProp.StorageClass.UUID));
                    end
                end
            end
        end



        for i=1:length(refs)
            dd.owner.addReferencedContainer(refs{i});
        end

        if coderdictionary.data.feature.getFeature('BuilltInMultiInstance')...
            &&ismember('Simulink',refs)
            coder.internal.CoderDataStaticAPI.delete(dd,'StorageClass',{'MultiInstance'});
        end
    end

