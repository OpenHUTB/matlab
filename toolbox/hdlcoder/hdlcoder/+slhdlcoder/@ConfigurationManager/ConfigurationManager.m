classdef ConfigurationManager<handle


    properties(Access=public)

        ModelName;


        ImplDB;


        DefaultTable;


        HereOnlyComponentTable;



        FrontEndStopTable;

        MergedConfigContainer;
    end
    methods
        function this=ConfigurationManager(mdlName,implDB)
            this.ModelName=mdlName;
            this.ImplDB=implDB;
            this.clearTables;
        end

        [isValid,isGlobal,isHereOnly,isBlock,isCustomLibBlock,slPath]=...
        analyzePath(this,path)

        clearTables(this)
        displayTables(this)
        disp(this)
        impl=getDefaultImplementation(this,block)
        [impl,implInfo]=getImplementationForBlock(this,slBlockPath)
        params=getSubsystemImplementationParams(this,slBlockPath)
        [impl,implInfo]=localGetImplementation(this,table,blockLibPath,slBlockPath)
        mergeConfigFiles(this,files,isDefault)
        pathName=normalizePathName(this,pathName)
        parseConfigStatements(this,hImplDatabase,configStmts,warnOnOverwrite)
        parseConfiguration(this,hImplDatabase,startNodeName,files)
        parseDefaultConfigs(this,hImplDatabase)
        parseUserBlockSettings(this,hImplDatabase,startNodeName)
        parseUserConfigs(this,hImplDatabase,configFiles)
        newPath=relativePathToSLPath(this,relativePath)
        saveMergedConfigFile(this,filename,implDB,nondefault)
        newPath=slPathToRelativePath(this,relativePath)
    end
end
