classdef ElementListRegistry < handle


















    properties ( Constant, Access = private )
        CacheFileName = "elements.mat";
    end

    properties ( Access = private )
        ModelToDiagramSIDToElementListMaps struct
        ModelToSubsystemReferenceSIDToElementListMaps struct
        NeedsToCloseCache logical
        DirtyModels struct
    end

    methods
        function this = ElementListRegistry(  )
            this.ModelToDiagramSIDToElementListMaps = struct(  );
            this.ModelToSubsystemReferenceSIDToElementListMaps = struct(  );
            this.DirtyModels = struct(  );
        end

        function delete( this )

            try
                if this.NeedsToCloseCache
                    slreportgen.webview.internal.CacheManager.instance(  ).close(  );
                end
            catch ME
                warning( ME.message );
            end
        end

        function out = get( this, diagram )



            if this.hasElementList( diagram )
                out = this.getElementList( diagram );
            else
                out = this.buildElementList( diagram );
            end





            if ~isempty( out ) && isempty( out( 1 ).referenceDiagram(  ) )
                for i = 1:numel( out )
                    out( i ).setReferenceDiagram( diagram );
                end
            end
        end

        function loadElementHandles( this, diagram )






            diagramH = diagram.handle(  );
            list = this.get( diagram );

            if isnumeric( diagramH )
                objHs = findBlocksAndAnnotations( diagramH );
                for i = 1:numel( objHs )
                    updateElement( list, objHs( i ) );
                end
                lines = findLines( diagramH );
                for i = 1:numel( lines )
                    updateElement( list, lines( i ) );
                end
            else
                objHs = findStateflowObjectsInView( diagramH );
                for i = 1:numel( objHs )
                    updateElement( list, objHs( i ) );
                end
            end
        end
    end

    methods ( Access = ?slreportgen.webview.internal.Cache )
        function save( this, cache )














            modelName = cache.ModelName;
            if isfield( this.DirtyModels, modelName ) ...
                    && isfield( this.ModelToDiagramSIDToElementListMaps, modelName )
                map = this.ModelToDiagramSIDToElementListMaps.( modelName );
                cacheFile = cache.createFile( this.CacheFileName );
                save( cacheFile, "map" );
            end
        end
    end

    methods ( Access = private )
        function tf = hasElementList( this, diagram )
            if diagram.Part.RootDiagram.IsModelReference
                modelName = diagram.Part.RootDiagram.RSID;
                dsid = diagram.RSID;
            else
                modelName = diagram.Model.Name;
                dsid = diagram.SID;
            end

            if diagram.Part.RootDiagram.IsSubsystemReference
                tf = isfield( this.ModelToSubsystemReferenceSIDToElementListMaps, modelName ) ...
                    && isKey( this.ModelToSubsystemReferenceSIDToElementListMaps.( modelName ), dsid );
            else
                tf = isfield( this.ModelToDiagramSIDToElementListMaps, modelName ) ...
                    && isKey( this.ModelToDiagramSIDToElementListMaps.( modelName ), dsid );
            end
        end

        function list = getElementList( this, diagram )
            if diagram.Part.RootDiagram.IsModelReference
                modelName = diagram.Part.RootDiagram.RSID;
                dsid = diagram.RSID;
            else
                modelName = diagram.Model.Name;
                dsid = diagram.SID;
            end

            if diagram.Part.RootDiagram.IsSubsystemReference
                list = this.ModelToSubsystemReferenceSIDToElementListMaps.( modelName )( dsid );
            else
                list = this.ModelToDiagramSIDToElementListMaps.( modelName )( dsid );
            end
        end

        function list = buildElementList( this, diagram )
            arguments
                this
                diagram
            end

            createdModelMap = false;
            modelName = diagram.Model.Name;
            if ~this.hasModelMap( modelName )
                this.createModelMap( modelName, diagram.Model.isBuiltWithCacheEnabled(  ) );
                createdModelMap = true;
            end

            if ( diagram.Part.RootDiagram.IsModelReference ...
                    || diagram.Part.RootDiagram.IsSubsystemReference )
                modelName = diagram.Part.RootDiagram.RSID;
                if ~this.hasModelMap( modelName )
                    this.createModelMap( modelName, diagram.Model.isBuiltWithCacheEnabled(  ) );
                    createdModelMap = true;
                end
            end

            if createdModelMap && this.hasElementList( diagram )


                list = this.getElementList( diagram );
            elseif diagram.Part.RootDiagram.IsSubsystemReference
                list = this.buildReferenceSubsystemElementList( diagram );
            else
                list = this.buildElementListFromSimulink( diagram );
            end
        end

        function list = buildElementListFromSimulink( this, diagram )

            diagramH = diagram.handle(  );
            if isnumeric( diagramH )

                objHs = findBlocksAndAnnotations( diagramH );
                nObjHs = numel( objHs );
                lines = findLines( diagramH );
                nLines = numel( lines );

                list = slreportgen.webview.internal.Element.empty( 0, nObjHs + nLines );
                for i = 1:nObjHs
                    builder = slreportgen.webview.internal.ElementBuilder(  );
                    builder.Handle = objHs( i );
                    list( i ) = builder.build(  );
                end
                count = 0;
                for i = 1:nLines
                    slobj = slreportgen.webview.SlProxyObject( lines( i ) );
                    if ~isempty( slobj.getId(  ) )
                        count = count + 1;
                        builder = slreportgen.webview.internal.ElementBuilder(  );
                        builder.SlProxyObject = slobj;
                        list( nObjHs + count ) = builder.build(  );
                    end
                end
            else

                objHs = findStateflowObjectsInView( diagramH );
                nObjHs = numel( objHs );
                list = slreportgen.webview.internal.Element.empty( 0, nObjHs );
                for i = 1:nObjHs
                    builder = slreportgen.webview.internal.ElementBuilder(  );
                    builder.Handle = objHs( i );
                    list( i ) = builder.build(  );
                end
            end

            if diagram.Part.RootDiagram.IsModelReference
                modelName = diagram.Part.RootDiagram.RSID;
                dsid = diagram.RSID;
            else
                modelName = diagram.Model.Name;
                dsid = diagram.SID;
            end

            partRootDiagram = diagram.Part.RootDiagram;
            if partRootDiagram.IsSubsystemReference
                for i = 1:numel( list )
                    element = list( i );
                    element.setRSID( strrep( element.SlProxyObjectID, partRootDiagram.SID, partRootDiagram.RSID ) )
                end

                this.ModelToSubsystemReferenceSIDToElementListMaps.( modelName )( dsid ) = list;

                if diagram.Model.isBuiltWithCacheEnabled(  )


                    referencedSubsystemList = copy( list );
                    for i = 1:numel( referencedSubsystemList )






                        referencedElement = referencedSubsystemList( i );
                        if ~isempty( referencedElement.SID )
                            referencedElement.setSID( referencedElement.rsid(  ) );
                        end
                        referencedElement.setSlProxyObjectID( referencedElement.rsid(  ) );
                    end
                    this.ModelToDiagramSIDToElementListMaps.( partRootDiagram.RSID )( diagram.RSID ) = referencedSubsystemList;

                    this.DirtyModels.( partRootDiagram.RSID ) = true;
                end
            else
                this.DirtyModels.( modelName ) = true;
                this.ModelToDiagramSIDToElementListMaps.( modelName )( dsid ) = list;
            end
        end

        function list = buildReferenceSubsystemElementList( this, diagram )

            partRootDiagram = diagram.Part.RootDiagram;
            refSubsysName = partRootDiagram.RSID;
            diagramSIDtoElementListMap = this.ModelToDiagramSIDToElementListMaps.( refSubsysName );
            if isKey( diagramSIDtoElementListMap, diagram.RSID )


                refSubsysElementList = diagramSIDtoElementListMap( diagram.RSID );
                list = copy( refSubsysElementList );
                refSubsysSID = partRootDiagram.SID;
                for i = 1:numel( list )





                    elem = list( i );
                    elem.setSID( strrep( elem.SID, refSubsysName, refSubsysSID ) );
                    elem.setSlProxyObjectID( strrep( elem.SlProxyObjectID, refSubsysName, refSubsysSID ) );
                end





                modelName = diagram.Model.Name;
                this.ModelToSubsystemReferenceSIDToElementListMaps.( modelName )( diagram.SID ) = list;

            else
                list = this.buildElementListFromSimulink( diagram );
            end
        end

        function tf = hasModelMap( this, modelName )
            tf = isfield( this.ModelToDiagramSIDToElementListMaps, modelName );



        end

        function map = createModelMap( this, modelName, useCache )
            cacheManager = slreportgen.webview.internal.CacheManager.instance(  );
            map = [  ];
            if useCache && ( cacheManager.isEnabled(  ) )
                if ~cacheManager.isOpen(  )
                    cacheManager.open(  );
                    this.NeedsToCloseCache = true;
                end

                cache = cacheManager.get( modelName );
                if ~isempty( cache )
                    cache.open(  );
                    cacheFile = cache.getFile( this.CacheFileName );
                    if ~isempty( cacheFile )


                        tmp = load( cacheFile );
                        map = tmp.map;
                    end


                    cache.addPreCloseCallback( @( x )this.save( x ) );
                end
            end

            if isempty( map )
                map = containers.Map(  );
            end
            this.ModelToDiagramSIDToElementListMaps.( modelName ) = map;
            this.ModelToSubsystemReferenceSIDToElementListMaps.( modelName ) = containers.Map(  );
        end
    end
end

function updateElement( list, objH )
slpobj = slreportgen.webview.SlProxyObject( objH );
for j = 1:numel( list )
    element = list( j );
    if ( element.SlProxyObjectID == slpobj.Id )
        element.setSlProxyObject( slpobj );
        break ;
    end
end
end

function out = findBlocksAndAnnotations( diagramH )
out = find_system( diagramH,  ...
    "IncludeCommented", "on",  ...
    "SearchDepth", 1,  ...
    'MatchFilter', @Simulink.match.allVariants,  ...
    "FindAll", "on",  ...
    "FollowLinks", "on",  ...
    "RegExp", 'on',  ...
    "LookUnderMasks", "all",  ...
    "Type", "block|annotation" );
out = out( 2:end  );
end

function out = findLines( diagramH )
diagramObj = slreportgen.utils.getSlSfObject( diagramH );
out = diagramObj.find( "-Depth", 1, "-isa", "Simulink.Line" );
end

function out = findStateflowObjectsInView( diagramH )
out = find( diagramH, "SubViewer", diagramH, "-not", "-isa", "Stateflow.Junction" );
end


