classdef EvolutionTreeManager <  ...
        evolutions.internal.datautils.SerializedAbstractInfoManager

    properties
        Profiles
    end

    methods ( Access = public )

        function obj = EvolutionTreeManager( project, rootFolder, artifactFolder )
            arguments
                project
                rootFolder = project.RootFolder;
                artifactFolder = 'EvolutionTrees';
            end
            obj = obj@evolutions.internal.datautils.SerializedAbstractInfoManager(  ...
                'evolutions.model.EvolutionTreeInfo', project,  ...
                rootFolder, artifactFolder );


            obj.Profiles = evolutions.internal.utils.makeCell( evolutions ...
                .internal.stereotypes.getDefaultProfileName );
        end

        epi = create( obj, name )
        epi = load( obj, varargin )
        save( obj )
        deleteEvolutionTree( obj, eti )
        loadArtifacts( obj )
        refreshEti( obj, eti )
        updateConstellationWithBackups( obj, constellation )
        syncTreesWithProject( obj )
        insert( obj, eti );


        eti = readDataFile( obj, constellation, xmlFile )
    end

    methods ( Access = protected )
        infos = getValidInfos( obj )
    end
end


