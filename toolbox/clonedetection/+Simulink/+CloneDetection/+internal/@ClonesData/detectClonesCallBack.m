function detectClonesCallBack(this)






    fileName=[pwd,filesep,'testFile.txt'];
    [fid,errmsg]=fopen(fileName,'w');
    if~isempty(errmsg)
        DAStudio.error('sl_pir_cpp:creator:folderPermissionDenied');
    else
        fclose(fid);
        delete(fileName);
    end



    this.blockPathCategoryMap=containers.Map('KeyType','char','ValueType','any');
    this.cloneGroupSidListMap=containers.Map('KeyType','char','ValueType','any');

    this.totalBlocks=0;
    populateExclusions(this);
    try

        loadedModels={};
        if~isempty(this.m2mObj)
            loadedModels=this.m2mObj.loadedModels;
        end

        initializeAndRunFindClones(this);

        this.m2mObj.loadedModels=[this.m2mObj.loadedModels;loadedModels];
    catch ME
        DAStudio.error(ME.message);
    end



    try
        if~this.isAcrossModel
            this.m2mObj.identify_clones(unique(this.excludeCloneDetection),str2double(this.parameterThreshold));
        else
            exclusionList=[];
            if~isempty(this.excludeCloneDetection)
                exclusionList=unique(this.excludeCloneDetection);
            end
            this.m2mObj.identify_clones(false,exclusionList,str2double(this.parameterThreshold));
        end

        if~isempty(this.m2mObj.cloneresult)
            this.m2mObj.cloneresult.exact=[];
            this.m2mObj.cloneresult.similar=[];

            if~this.isAcrossModel&&~isempty(this.libraryList)
                this.populateLibraryCloneResults(this.m2mObj);
            else
                this.populateExactAndSimilarCloneResults(this.m2mObj);
            end
        end
    catch ME
        DAStudio.error(ME.message);
    end

    try
        if~isempty(this.m2mObj.cloneresult)
            constructHelperMaps(this);
        end

        if~isempty(this.libraryList)
            if~isempty(this.m2mObj.cloneresult)
                calculateRefactorBenefitsForLib(this);
            end
        end

        if~exist(this.m2mObj.m2m_dir,'dir')
            mkdir(this.m2mObj.m2m_dir);
            this.backUpPath=this.m2mObj.m2m_dir;
            this.historyVersions=[];
            saveNewHistoryVersion(this);
        elseif~isempty(this.historyVersions)

            check=checkSettings(this);
            if check||~this.cloneDetectionStatus
                saveNewHistoryVersion(this);
            end
        else

            saveNewHistoryVersion(this);
        end

        this.cloneDetectionStatus=~isempty(this.m2mObj.cloneresult);

    catch ME
        DAStudio.error(ME.message);
    end
end


function calculateRefactorBenefitsForLib(this)
    UniqueSimilarBlocks=containers.Map('KeyType','char','ValueType','any');
    UniqueExactBlocks=containers.Map('KeyType','char','ValueType','any');
    this.metrics=struct('overAllPotentialReuse',0,'exactPotentialReuse',0,'similarPotentialReuse',0);
    for i=1:length(this.m2mObj.cloneresult.Before.mdlBlks)
        if~this.m2mObj.cloneresult.Before.similarCloneFlag{i}
            for j=1:length(this.m2mObj.cloneresult.Before.mdlBlks{i})
                if~isKey(UniqueExactBlocks,this.m2mObj.cloneresult.Before.mdlBlks{i}{j})
                    UniqueExactBlocks(this.m2mObj.cloneresult.Before.mdlBlks{i}{j})=1;
                end
            end
        else
            for j=1:length(this.m2mObj.cloneresult.Before.mdlBlks{i})
                if~isKey(UniqueSimilarBlocks,this.m2mObj.cloneresult.Before.mdlBlks{i}{j})
                    UniqueSimilarBlocks(this.m2mObj.cloneresult.Before.mdlBlks{i}{j})=1;
                end
            end
        end
    end
    this.metrics.overAllPotentialReuse=length(UniqueSimilarBlocks)+length(UniqueExactBlocks);
    this.metrics.exactPotentialReuse=length(UniqueExactBlocks);
    this.metrics.similarPotentialReuse=length(UniqueSimilarBlocks);
end

function initializeAndRunFindClones(this)
    if this.isAcrossModel
        this.m2mObj=slEnginePir.acrossModelGraphicalCloneDetection(this.listOfFolders,...
        this.systemFullName,'struct',this.ignoreSignalName,this.ignoreBlockProperty,...
        ~this.excludeModelReferences,~this.excludeLibraries,~this.excludeInactiveRegions,...
        this.isReplaceExactCloneWithSubsysRef,this.FindClonesRecursivelyInFolders,...
        this.enableClonesAnywhere,this.regionSize,this.cloneGroupSize);
        this.m2mObj.m2m_dir=this.backUpPath;
        this.populateExclusionsForAcrossModels();
    elseif~isempty(this.libraryList)
        libraryfile=this.libraryList;
        this.m2mObj=slEnginePir.libraryPatternClones(libraryfile,...
        this.systemFullName,'struct',~this.excludeModelReferences,...
        ~this.excludeLibraries,this.ignoreSignalName,this.ignoreBlockProperty);
    elseif this.excludeInactiveRegions
        this.m2mObj=slEnginePir.SystemCompileCloneDetection(this.systemFullName,...
        'struct',this.enableClonesAnywhere,~this.excludeModelReferences,~this.excludeLibraries,...
        this.ignoreSignalName,this.ignoreBlockProperty);
        this.m2mObj.isReplaceExactCloneWithSubsysRef=this.isReplaceExactCloneWithSubsysRef;
    else
        this.m2mObj=slEnginePir.SystemGraphicalCloneDetection(this.systemFullName,'struct',this.enableClonesAnywhere,~this.excludeModelReferences,~this.excludeLibraries);
        this.m2mObj.isReplaceExactCloneWithSubsysRef=this.isReplaceExactCloneWithSubsysRef;
        if this.enableClonesAnywhere
            if slfeature('CloneAnywhereOptimized')==1
                this.m2mObj.runCloneAnywhere('StructuralParameters',this.regionSize,this.cloneGroupSize,this.ignoreSignalName,this.ignoreBlockProperty,~this.excludeLibraries);
            else
                this.m2mObj.runCloneAnywhere('struct',this.regionSize,this.cloneGroupSize,this.ignoreSignalName,this.ignoreBlockProperty,~this.excludeLibraries);
            end

        elseif(this.parameterThreshold=="0"||this.isReplaceExactCloneWithSubsysRef)
            this.m2mObj.runCloneDetection('StructuralParameters',this.ignoreSignalName,this.ignoreBlockProperty);
        else
            this.m2mObj.runCloneDetection('struct',this.ignoreSignalName,this.ignoreBlockProperty);
        end
    end
end




function check=checkSettings(this)
    check=0;
    len=length(this.historyVersions);
    latestVer=this.historyVersions(len);
    try
        loadedObject=load([['m2m_',get_param(this.model,'name')],'/',char(latestVer),'.mat']);
    catch
        check=1;
        return;
    end
    latestVersionObj=loadedObject.updatedObj;

    if~isequal(this.libraryList,latestVersionObj.libraryList)
        check=1;
        return;
    end

    if~isequal(this.excludeCloneDetection,latestVersionObj.excludeCloneDetection)
        check=1;
        return;
    end

    if~isequal(this.isReplaceExactCloneWithSubsysRef,latestVersionObj.isReplaceExactCloneWithSubsysRef)
        check=1;
        return;
    end

    if~isequal(this.parameterThreshold,latestVersionObj.parameterThreshold)
        check=1;
    end


    if strcmp(get_param(this.model,'Dirty'),'on')
        check=1;
    end

    if strcmp(get_param(this.model,'SavedSinceLoaded'),'on')
        check=1;
    end
end


