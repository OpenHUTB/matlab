classdef CacheManager<handle




    properties(Transient)
tmpMFModel
    end
    methods
        function obj=CacheManager()
            obj.tmpMFModel=mf.zero.Model;
        end

        function out=hasCachedLegacySpecificationsInMemory(~,package)

            inst=coderdictionary.data.api.getCachedInstance(package);
            out=false;
            if~isempty(inst)&&inst.isvalid&&~inst.isEmpty
                out=true;
            end
        end

        function cache=getPackageCache(obj,packageName)


            import coder.internal.CoderDataStaticAPI.*;


            if obj.hasCachedLegacySpecificationsInMemory(packageName)
                cache=obj.loadPackageFromMemory(packageName);
            else
                ddFName=obj.getDDForPackage(packageName);
                if exist(ddFName,'file')==2

                    coderdictionary.data.api.loadBuiltin();
                    cache=obj.loadPackageFromMemory(packageName);
                    return;
                else

                    cache=Utils.importLegacyPackage(packageName,obj.tmpMFModel);
                end

                chksumStruct=processcsc('GetCSCChecksums',packageName);
                chksum=chksumStruct.Checksum;
                chksumSrc=chksumStruct.ChecksumSource;
                [~,fName,fExt]=fileparts(chksumSrc.(packageName));
                cache.addLegacyPackageChecksum(packageName,chksum.(packageName),[fName,fExt]);

                obj.cacheLegacySpecificationsInMemory(packageName,cache);
                cache=cache.owner;
            end
        end
        function loadPackage(obj,packageName,destDictionary)


            import coder.internal.CoderDataStaticAPI.*;
            hlp=coder.internal.CoderDataStaticAPI.getHelper;
            destDictionary=hlp.openDD(destDictionary);
            if ismember(packageName,getPackagesWithShippingSLDDs)
                found=destDictionary.owner.hasReferencedContainer(packageName);


                if~found&&~ismember(packageName,destDictionary.getLegacyPackageNames)
                    destDictionary.owner.addReferencedContainer(packageName);
                end
            else
                cache=obj.getPackageCache(packageName);

                Utils.copyDictionary(cache,destDictionary);

                if isa(cache,'coderdictionary.data.Container')
                    cdef=cache.CDefinitions;
                elseif isa(cache,'coderdictionary.data.C_Definitions')
                    cdef=cache;
                else
                    return;
                end
                chksum=cdef.packageChecksums.getByKey(packageName);
                dst=destDictionary;
                if~isa(dst,'coderdictionary.data.C_Definitions')
                    hlp=coder.internal.CoderDataStaticAPI.getHelper;
                    dst=hlp.openDD(destDictionary);
                end

                if~isempty(chksum)
                    dst.addLegacyPackageChecksum(packageName,...
                    chksum.Checksum,chksum.ChecksumSource);
                end
            end
        end

        function reset(~)

            coderdictionary.data.api.clearCache();
        end

        function clearPackageInCache(~,packageName)

            coderdictionary.data.api.clearPackageInCache(packageName);
        end

        function refreshPackage(cm,dict)
            hlp=coder.internal.CoderDataStaticAPI.getHelper();
            dd=hlp.openDD(dict);
            [shippingPackages,containerIDs]=coder.internal.CoderDataStaticAPI.getPackagesWithShippingSLDDs;
            if ismember(dd.owner.ID,containerIDs)
                isShippingSLDD=true;

                currentPkg=dd.getLegacyPackageNames();
            else
                isShippingSLDD=false;

                currentPkg=coder.internal.CoderDataStaticAPI.getCurrentNonBuiltinPackages(dd);
            end
            txn=[];
            try
                txn=hlp.beginTxn(dd);


                if~isempty(currentPkg)||isShippingSLDD

                    scsMap=containers.Map;
                    mssMap=containers.Map;
                    scs=coder.internal.CoderDataStaticAPI.get(dd,'StorageClass');
                    mss=coder.internal.CoderDataStaticAPI.get(dd,'MemorySection');
                    for i=1:length(scs)
                        if isa(scs(i),'coderdictionary.data.LegacyStorageClass')
                            package=scs(i).Package;
                            className=scs(i).ClassName;
                            if isKey(scsMap,package)
                                scsMap(package)=[scsMap(package),className];
                            else
                                scsMap(package)={className};
                            end
                        end
                    end
                    for i=1:length(mss)
                        if isa(mss(i),'coderdictionary.data.LegacyMemorySection')
                            package=mss(i).Package;
                            className=mss(i).ClassName;
                            if isKey(mssMap,package)
                                mssMap(package)=[mssMap(package),className];
                            else
                                mssMap(package)={className};
                            end
                        end
                    end
                    pkgsOwnedByDict=coder.internal.CoderDataStaticAPI.Utils.getPackagesOwnedByDictionary(dd);
                    for i=1:length(currentPkg)
                        package=currentPkg{i};



                        if~isShippingSLDD&&ismember(package,shippingPackages)&&...
                            ~ismember(package,pkgsOwnedByDict)




                            if~isempty(dd.packageChecksums.getByKey(package))
                                chksumStruct=processcsc('GetCSCChecksums',package);
                                chksum=chksumStruct.Checksum;
                                chksumSrc=chksumStruct.ChecksumSource;
                                [~,fName,fExt]=fileparts(chksumSrc.(package));
                                dd.addLegacyPackageChecksum(package,chksum.(package),[fName,fExt]);
                            end
                            continue;
                        end

                        cm.clearPackageInCache(package);

                        cm.getPackageCache(package);


                        cscs=processcsc('GetCSCDefns',package);
                        cscInPkg=cell(size(cscs));
                        for ii=1:numel(cscs)
                            csc=cscs(ii);
                            cscInPkg{ii}=csc.Name;
                        end
                        cmss=processcsc('GetMemorySectionDefns',package);
                        mssInPkg=cell(size(cmss));
                        for ii=1:numel(cmss)
                            cms=cmss(ii);
                            mssInPkg{ii}=cms.Name;
                        end


                        if isKey(scsMap,package)
                            removedSCs=setdiff(scsMap(package),cscInPkg);
                            for ii=1:numel(removedSCs)
                                name=removedSCs{ii};
                                hlp.deleteEntry(dd,...
                                'AbstractStorageClass',[package,'_',name]);
                            end
                        end
                        if isKey(mssMap,package)
                            removedMSs=setdiff(mssMap(package),mssInPkg);
                            for ii=1:numel(removedMSs)
                                name=removedMSs{ii};
                                hlp.deleteEntry(dd,...
                                'AbstractMemorySection',[package,'_',name]);
                            end
                        end



                        coder.internal.CoderDataStaticAPI.importLegacyMS(dd,package);
                        coder.internal.CoderDataStaticAPI.importCsc(dd,package,{});



                        chksumStruct=processcsc('GetCSCChecksums',package);
                        chksum=chksumStruct.Checksum;
                        chksumSrc=chksumStruct.ChecksumSource;
                        [~,fName,fExt]=fileparts(chksumSrc.(package));
                        dd.addLegacyPackageChecksum(package,chksum.(package),[fName,fExt]);
                    end
                end
                hlp.commitTxn(txn);
            catch me
                if~isempty(txn)
                    hlp.rollbackTxn(txn);
                end


                rethrow(me);
            end
        end
    end

    methods(Access=private)

        function ddPath=getCachedDictionaryPath(~)
            ddPath=fullfile(matlabroot,'toolbox','shared','simulinkcoder','coderdictionary','shipping_dict');
        end

        function ddFName=getDDForPackage(obj,packageName)
            ddPath=obj.getCachedDictionaryPath();
            if strcmp(packageName,'Simulink')&&...
                coderdictionary.data.feature.getFeature('BuiltinMultiInstance')
                ddFName=fullfile(ddPath,'SimulinkMultiInstance.sldd');
            else
                ddFName=fullfile(ddPath,[packageName,'.sldd']);
            end
        end

        function dd=loadPackageFromMemory(obj,packageName)
            dd=[];
            if obj.hasCachedLegacySpecificationsInMemory(packageName)
                dd=coderdictionary.data.api.getCachedInstance(packageName);
            end
        end

        function cacheLegacySpecificationsInMemory(obj,package,legacySrcDict)
            import coder.internal.CoderDataStaticAPI.*;
            hlp=getHelper();
            if~obj.hasCachedLegacySpecificationsInMemory(package)
                [srcDef,~,~]=hlp.openDD(legacySrcDict);
                txn=hlp.beginTxn(srcDef);
                coderdictionary.data.api.cacheInstance(package,srcDef.owner);
                hlp.commitTxn(txn);
            end
        end
    end
end


