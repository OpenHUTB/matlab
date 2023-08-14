function copyDictionary(src,dst,varargin)






    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();
    actionType='copy';
    if(nargin==3)
        actionType=varargin{1};
    end


    slRoot=slroot;
    if slRoot.isValidSlObject(src)&&slRoot.isValidSlObject(dst)
        [srcDef,~,~]=hlp.openDD(src,'C',true);
        [dstDef,~,dstDD]=hlp.openDD(dst,'C',true);
    else
        [srcDef,~,~]=hlp.openDD(src);
        [dstDef,~,dstDD]=hlp.openDD(dst);
    end

    if coderdictionary.data.api.isFrozen(dstDD)

        return;
    end

    srcHasSCsToCopy=~isempty(hlp.getCoderData(srcDef,'StorageClass'));
    srcHasFCsToCopy=~isempty(hlp.getCoderData(srcDef,'FunctionClass'));
    if strcmp(actionType,'paste')&&...
        ~(srcHasSCsToCopy||srcHasFCsToCopy)



        msUuid2NameSrc=locCopyMemorySections(srcDef,dstDef);
    elseif~strcmp(actionType,'paste')










        msUuid2NameSrc=locCopyMemorySections(srcDef,dstDef);
    end
    fcUuid2NameSrc=locCopyFunctionClasses(srcDef,dstDef);
    scUuid2NameSrc=locCopyStorageClasses(srcDef,dstDef);
    slRoot=slroot;


    if slRoot.isValidSlObject(src)&&~slRoot.isValidSlObject(dst)

        msName2UuidDest=containers.Map();
        fcName2UuidDest=containers.Map();
        scName2UuidDest=containers.Map();

        memorySections=hlp.getCoderData(dstDef,'MemorySection');
        for ii=1:numel(memorySections)
            msName2UuidDest(memorySections(ii).Name)=memorySections(ii).UUID;
        end
        functionClasses=hlp.getCoderData(dstDef,'FunctionClass');
        for ii=1:numel(functionClasses)
            fcName2UuidDest(functionClasses(ii).Name)=functionClasses(ii).UUID;
        end
        storageClasses=hlp.getCoderData(dstDef,'StorageClass');
        for ii=1:numel(storageClasses)
            scName2UuidDest(storageClasses(ii).Name)=storageClasses(ii).UUID;
        end


        modelMapping=Simulink.CodeMapping.get(src,'CoderDictionary');
        if~isempty(modelMapping)
            defMapping=modelMapping.DefaultsMapping;

            remapDataDefUuids(defMapping.Inports,scUuid2NameSrc,scName2UuidDest,msUuid2NameSrc,msName2UuidDest);
            remapDataDefUuids(defMapping.Outports,scUuid2NameSrc,scName2UuidDest,msUuid2NameSrc,msName2UuidDest);
            remapDataDefUuids(defMapping.GlobalParameters,scUuid2NameSrc,scName2UuidDest,msUuid2NameSrc,msName2UuidDest);
            remapDataDefUuids(defMapping.SharedParameters,scUuid2NameSrc,scName2UuidDest,msUuid2NameSrc,msName2UuidDest);
            remapDataDefUuids(defMapping.PerInstanceParameters,scUuid2NameSrc,scName2UuidDest,msUuid2NameSrc,msName2UuidDest);
            remapDataDefUuids(defMapping.SharedLocalDataStores,scUuid2NameSrc,scName2UuidDest,msUuid2NameSrc,msName2UuidDest);
            remapDataDefUuids(defMapping.GlobalDataStores,scUuid2NameSrc,scName2UuidDest,msUuid2NameSrc,msName2UuidDest);
            remapDataDefUuids(defMapping.InternalData,scUuid2NameSrc,scName2UuidDest,msUuid2NameSrc,msName2UuidDest);
            remapDataDefUuids(defMapping.Constants,scUuid2NameSrc,scName2UuidDest,msUuid2NameSrc,msName2UuidDest);
            remapDataDefUuids(defMapping.ModelData,scUuid2NameSrc,scName2UuidDest,msUuid2NameSrc,msName2UuidDest);

            remapFcnDefUuids(defMapping.InitTermFunctions,fcUuid2NameSrc,fcName2UuidDest,msUuid2NameSrc,msName2UuidDest);
            remapFcnDefUuids(defMapping.ExecutionFunctions,fcUuid2NameSrc,fcName2UuidDest,msUuid2NameSrc,msName2UuidDest);
            remapFcnDefUuids(defMapping.SharedUtilityFunctions,fcUuid2NameSrc,fcName2UuidDest,msUuid2NameSrc,msName2UuidDest);
        end
    end

end

function msUuid2NameSrc=locCopyMemorySections(srcDD,dstDD)
    import coder.internal.CoderDataStaticAPI.*;
    msUuid2NameSrc=containers.Map;
    hlp=getHelper;
    memorySections=hlp.getCoderData(srcDD,'MemorySection');
    for i=1:length(memorySections)
        currentMS=memorySections(i);
        msUuid2NameSrc(currentMS.UUID)=currentMS.Name;
        currentMS.copyTo(dstDD);
    end
end

function fcUuid2NameSrc=locCopyFunctionClasses(srcDD,dstDD)
    import coder.internal.CoderDataStaticAPI.*;
    fcUuid2NameSrc=containers.Map;
    hlp=getHelper;
    functionClasses=hlp.getCoderData(srcDD,'FunctionClass');
    for i=1:length(functionClasses)
        currentFC=functionClasses(i);
        fcUuid2NameSrc(currentFC.UUID)=currentFC.Name;
        currentFC.copyTo(dstDD);
    end
end

function scUuid2NameSrc=locCopyStorageClasses(srcDD,dstDD)
    import coder.internal.CoderDataStaticAPI.*;
    scUuid2NameSrc=containers.Map;
    hlp=getHelper;
    storageClasses=hlp.getCoderData(srcDD,'StorageClass');
    for i=1:length(storageClasses)
        currentSC=storageClasses(i);
        scUuid2NameSrc(currentSC.UUID)=currentSC.Name;


        if~currentSC.isBuiltin||isempty(dstDD.findEntry('StorageClass',currentSC.Name))
            currentSC.copyTo(dstDD);
        end
    end
end

function remapDataDefUuids(category,scUuid2NameSrc,scName2UuidDest,msUuid2NameSrc,msName2UuidDest)

    sc=category.StorageClass;
    if~isempty(sc)&&~isempty(sc.UUID)
        if scUuid2NameSrc.isKey(sc.UUID)
            name=scUuid2NameSrc(sc.UUID);
            if scName2UuidDest.isKey(name)
                sc.UUID=scName2UuidDest(name);
            end
        end
    end
    ms=category.MemorySection;
    if~isempty(ms)&&~isempty(ms.UUID)
        if msUuid2NameSrc.isKey(ms.UUID)
            name=msUuid2NameSrc(ms.UUID);
            if msName2UuidDest.isKey(name)
                ms.UUID=msName2UuidDest(name);
            end
        end
    end
end

function remapFcnDefUuids(category,fcUuid2NameSrc,fcName2UuidDest,msUuid2NameSrc,msName2UuidDest)

    fc=category.FunctionClass;
    if~isempty(fc)&&~isempty(fc.UUID)
        if fcUuid2NameSrc.isKey(fc.UUID)
            name=fcUuid2NameSrc(fc.UUID);
            if fcName2UuidDest.isKey(name)
                fc.UUID=fcName2UuidDest(name);
            end
        end
    end
    ms=category.MemorySection;
    if~isempty(ms)&&~isempty(ms.UUID)
        if msUuid2NameSrc.isKey(ms.UUID)
            name=msUuid2NameSrc(ms.UUID);
            if msName2UuidDest.isKey(name)
                ms.UUID=msName2UuidDest(name);
            end
        end
    end
end



