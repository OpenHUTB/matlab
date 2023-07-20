classdef HDLImplDatabase<handle

    properties(Access=private)










        BlockDB;

















        DescriptionDB;





        ConfigFiles;




        LibraryDB;


        abstractClasses;
    end

    methods
        function this=HDLImplDatabase
            this.clearDatabase;
        end

        value=blockTagExists(this,slBlockPath)
        buildDatabase(this,enableDeprecation,pluginList)
        buildLibrary(this,cm,options)
        dupName=checkForDuplicateShortListing(this,curImpls,description)
        clearDatabase(this)
        dispDatabase(this)
        dispHelpTags(this)
        dispImplementations(this,showBlks)
        dispIRBlocks(this)
        dispIRImplementations(this)
        disp(this)
        [impl2blkmap,blockList]=dispNFPImplementations(this,dumpToFile,showBlks)
        dispSupportedBlocks(this)
        value=getBlock(this,slBlockPath)
        blocks=getBlocksFromImplementation(this,implementation)
        tags=getBlockTags(this)
        files=getConfigurationFiles(this)
        value=getDescription(this,tag)
        desc=getDescriptionsFromBlock(this,slBlockPath)
        tags=getDescriptionTags(this)
        implementationClass=getImplementationForArch(this,blockLibPath,archName)
        [hdlblkinfo,deprInfo,hdlblkInfoHide,helpInfo]=getImplementationInfoForBlock(this,blkTag,filterHidden,curArch,blockHandle)
        classnames=getImplementationsFromBlock(this,blkTag)
        [newImpls,implpvpairs]=getPublishedImplementations(this,blockLibPath)
        hdlblkinfo=getSubsystemImplInfo(this)
        blocks=getSupportedBlocks(this)
        libraries=getSupportedLibraries(this)
        sysObjIdxes=getSystemObjectIndices(~,blocks)
        isABC=isAbstractBaseClass(this,implementationName)
        found=isRegistered(this,slBlockPath,implementationName)
        oldbuildLibrary(this)
        setBlock(this,slBlockPath,value)
        setDescription(this,tag,value)
    end

    methods(Static,Access=public)
        libraryNames=getFullySupportedLibraries;
    end
end
