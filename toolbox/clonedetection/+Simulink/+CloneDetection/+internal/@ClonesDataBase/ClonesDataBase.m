classdef ClonesDataBase < handle

    properties
        model = '';
        systemFullName = '';
        backUpPath = '';
        historyVersions = [  ];
        m2mObj = [  ];
        isAcrossModel = false;
        listOfFolders = {  };
        libraryList = {  };
        excludeLibraries = false;
        excludeModelReferences = false;
        excludeInactiveRegions = false;
        excludeCloneDetection = [  ];
        defaultThreshold = '50';
        parameterThreshold;
        parameterThreshold_old;
        refactorOptions;
        backupModel = '';
        objectFile = '';

        blockPathCategoryMap;
        cloneGroupSidListMap;

        refactoredClonesLibFileName = 'newLibraryFile';
        cloneDetectionStatus = false;
        metrics = struct( 'overAllPotentialReuse', 0,  ...
            'exactPotentialReuse', 0, 'similarPotentialReuse', 0 );
        totalBlocks = 0;
        ignoreSignalName = false;
        ignoreBlockProperty = false;
        isReplaceExactCloneWithSubsysRef = false;
        enableClonesAnywhere = false;
        regionSize = 2;
        cloneGroupSize = 2;
        CloneResults = [  ];
        ReplaceResults = [  ];
        EquivalencyCheckResults = [  ];
    end

    methods
        function this = ClonesDataBase( modelName )
            arguments
                modelName = ''
            end
            this.backUpPath = this.getResultsFolderName( modelName );
            if ~isempty( modelName )
                this.model = get_param( bdroot( modelName ), 'handle' );
                this.systemFullName = modelName;
                this.m2mObj = slEnginePir.SystemGraphicalCloneDetection(  ...
                    this.systemFullName, 'struct' );
            end



            excludeMsg = DAStudio.message( 'sl_pir_cpp:creator:Exclude' );
            this.refactorOptions = { excludeMsg, excludeMsg, excludeMsg, excludeMsg, excludeMsg, excludeMsg, excludeMsg };
            this.parameterThreshold = this.defaultThreshold;
            this.parameterThreshold_old = this.defaultThreshold;
            this.blockPathCategoryMap = containers.Map( 'KeyType', 'char', 'ValueType', 'any' );
            this.cloneGroupSidListMap = containers.Map( 'KeyType', 'char', 'ValueType', 'any' );
        end

        function [ resultsFolderName ] = getResultsFolderName( ~, modelName )
            resultsFolderName = [ Simulink.CloneDetection.internal.util.getResultsFolderName( modelName ), '/' ];
        end

        function setParameterThreshold( obj, value )
            if ~isempty( obj.toolstripCtx ) && isvalid( obj.toolstripCtx )
                obj.toolstripCtx.parameterThreshhold = value;
            end
            obj.parameterThreshold = value;
        end


        function saveNewHistoryVersion( this )
            newVersion = [ 'Results-', char( datetime( 'now', 'TimeZone', 'local', 'Format',  ...
                'yyyy-MM-dd-HH-mm-ss' ) ) ];


            this.objectFile = [ this.backUpPath, newVersion, '.mat' ];
            this.historyVersions =  ...
                Simulink.CloneDetection.internal.util.getHistoryVersionsForClonesData(  ...
                this.backUpPath );
            this.historyVersions = [ this.historyVersions, { newVersion } ];
            updatedObj = this;
            save( this.objectFile, 'updatedObj' );
        end

        function exclusions = getExclusions( ~, model )
            exclusionsObj = CloneDetector.Exclusions(  );
            exclusionsObj.retrieveExclusions( get_param( model, 'name' ) );
            exclusions = exclusionsObj.getExcludedBlocks(  );


        end
    end

    methods ( Access = 'protected' )
        constructHelperMaps( obj );
    end
end


