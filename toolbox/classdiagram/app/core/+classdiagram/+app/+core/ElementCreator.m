classdef ElementCreator

    properties
        App;
        UuidToObjectMap;
    end

    properties ( Constant )
        Constants = classdiagram.app.core.utils.Constants;
    end

    methods
        function obj = ElementCreator( app, uuidToObjectMap )
            obj.App = app;
            obj.UuidToObjectMap = uuidToObjectMap;
        end
    end

    methods ( Access = private )

        function sortedMembers = sortBaseObjectsArrayByName( ~, toSort )
            pNames = arrayfun( @( m )string( m.getName(  ) ), toSort );
            [ ~, idx ] = sort( upper( pNames ) );
            sortedMembers = toSort( idx );
        end

        function createMetadataForDiagramEntity( ~, operations, diagramEntity, meta )
            if isempty( meta )
                operations.setAttributeValue( diagramEntity, "Metadata", "" );
                return ;
            end
            attrValue = '';
            for k = keys( meta )
                key = k{ 1 };
                attrValue = attrValue + " " + key + "-" + meta( key ) + " ";
            end
            operations.setAttributeValue( diagramEntity, "Metadata", attrValue );
        end

        function entity = createDiagramEntity( ~, operations, title, type, parentDiagram )

            entity = operations.createEntity( parentDiagram );
            operations.setTitle( entity, title );
            operations.setType( entity, type );
        end

        function entity = createDiagramEntityForBaseObject( self, operations, baseObject, parentDiagram )

            entity = operations.createEntity( parentDiagram );
            operations.setTitle( entity, baseObject.getName(  ) );
            operations.setType( entity, classdiagram.app.core.domain.ClassDiagramTypes.typeMap( baseObject.getType(  ) ) );
            baseObject.setDiagramElementUUID( entity.uuid );
            operations.setAttributeValue( entity, 'ObjectID', baseObject.getObjectID(  ) );
            self.createMetadataForDiagramEntity( operations, entity, baseObject.getMetadata(  ) );

            baseObject.setDiagramElementUUID( entity.uuid );

            self.UuidToObjectMap( entity.uuid ) = baseObject;

        end

        function updateDiagramEntityForBaseObject( self, operations, entity, baseObject )
            operations.setTitle( entity, baseObject.getName(  ) );
            operations.setType( entity,  ...
                classdiagram.app.core.domain.ClassDiagramTypes.typeMap(  ...
                baseObject.getType(  ) ) );
            baseObject.setDiagramElementUUID( entity.uuid );
            operations.setAttributeValue( entity, 'ObjectID', baseObject.getObjectID(  ) );
            self.createMetadataForDiagramEntity( operations, entity, baseObject.getMetadata(  ) );

            baseObject.setDiagramElementUUID( entity.uuid );

            self.UuidToObjectMap( entity.uuid ) = baseObject;

        end

        function lines = createDiagramEntityForClassMembers( self, operations, members, subtitle, titleType, parentDiagram, toCollapse )
            lines = [  ];
            if isempty( members )
                return ;
            end
            members( arrayfun( @( m )m.isHidden, members ) ) = [  ];
            if isempty( members )
                return ;
            end
            sortedMembers = members;
            if ~strcmp( titleType, "ValueTitle" )
                sortedMembers = self.sortBaseObjectsArrayByName( members );
            end
            subtitle = self.createDiagramEntity( operations, subtitle, "subtitle", parentDiagram );
            operations.setAttributeValue( subtitle, "TitleType", titleType );
            operations.setAttributeValue( subtitle, "collapsed", toCollapse );
            lines = diagram.interface.Entity.empty( 0, numel( sortedMembers ) + 1 );
            lines( 1 ) = subtitle;
            for imember = 1:numel( sortedMembers )
                member = sortedMembers( imember );
                line = self.createDiagramEntityForBaseObject( operations, member, parentDiagram );
                operations.setAttributeValue( line, "collapsed", toCollapse );
                lines( imember + 1 ) = line;
            end
        end

        function addPropertyDomainTypeToTitle( self, operations, properties )
            for iprop = 1:numel( properties )
                prop = properties( iprop );
                if prop.isHidden
                    continue ;
                end
                propElement = self.App.syntax.findElement( prop.getDiagramElementUUID(  ) );
                domainType = prop.getDomainType(  );
                if ~isempty( domainType )



                    operations.setAttributeValue( propElement, 'ValueType', domainType );
                    t = strsplit( domainType, '.' );
                    nonQualifiedDomainType = t{ length( t ) };
                    name = [ char( prop.getName(  ) ), ': ', nonQualifiedDomainType ];
                    operations.setTitle( propElement, name );
                end
            end
        end

        function classentity = elementCreateUpdateHelper( self, operations, class, parentDiagram )
            arguments
                self( 1, 1 )classdiagram.app.core.ElementCreator;
                operations( 1, 1 )diagram.interface.Operations;
                class( 1, 1 )classdiagram.app.core.domain.PackageElement;
                parentDiagram diagram.interface.Diagram = diagram.interface.Diagram.empty;
            end

            className = class.getName;
            peTitleHeight = self.Constants.ClassTitleHeight;
            if isa( class, 'classdiagram.app.core.domain.Enum' )
                peTitleHeight = self.Constants.EnumTitleHeight;
            end




            owningPackage = class.getOwningPackage(  );
            if isempty( owningPackage )
                owningPackageName = "";
            else
                owningPackageName = owningPackage.getName(  );
                if isempty( parentDiagram )
                    owningPackage.clearCaches;
                end
            end

            if ~isempty( parentDiagram )
                classentity = self.createDiagramEntityForBaseObject( operations, class, parentDiagram );
                operations.createSubdiagram( classentity );

                width = self.Constants.ClassWidth;
                if self.App.getGlobalSetting( 'InitiallyCollapsed' )
                    operations.setAttributeValue( classentity, "collapsed", true );
                end
            else
                classentity = self.App.findEntity( className );
                self.updateDiagramEntityForBaseObject( operations, classentity, class );
                width = classentity.getSize.width;
            end

            operations.setAttributeValue( classentity, "OwningPackage", owningPackageName );
            operations.setAttributeValue( classentity, "SuperclassNames", class.getSuperclassNames );
            operations.setAttributeValue( classentity, "InheritanceFlags", int8( class.getInheritanceFlags ) );

            nlines = 0.5;
            fullExpandedState = self.getFullExpandedState( classentity );
            if ~fullExpandedState.expanded
                operations.setSize( classentity, width, peTitleHeight + nlines * self.Constants.LineHeight );
                return ;
            end
            nlines = nlines + self.createClassMembers( operations, Class = class );
            operations.setSize( classentity, width, peTitleHeight + nlines * self.Constants.LineHeight );
        end

        function sectionExpandedState = getSectionExpandState( ~, container )
            sectionExpandedState = struct;
            section = [  ];
            for iitem = 1:numel( container.entities )
                item = container.entities( iitem );
                if item.type == "subtitle"
                    section = item.title;
                    sectionExpandedState.( section ) = true;
                else
                    if ~isempty( section )
                        if item.hasAttribute( "collapsed" )
                            sectionExpandedState.( section ) = item.getAttribute( "collapsed" ).value ~= 1;
                        end
                    end
                end
            end
        end

        function fullExpandedState = getFullExpandedState( self, classentity )

            fullExpandedState = struct( "entity", classentity.title,  ...
                "expanded", ~classentity.hasAttribute( "collapsed" ) || ( classentity.getAttribute( "collapsed" ).value ~= 1 ),  ...
                "sections", self.getSectionExpandState( classentity.subdiagram ) ...
                );
        end
    end

    methods

        function classentity = createDiagramEntityForPackageElement( self, operations, class, parentDiagram )

            classentity = self.elementCreateUpdateHelper( operations, class, parentDiagram );
        end

        function updateDiagramEntityMetadata( self, operations, element )
            className = element.getName;
            classentity = self.App.findEntity( className );
            if isempty( classentity )
                return ;
            end
            self.createMetadataForDiagramEntity( operations, classentity, element.getMetadata );
        end

        function classentity = updateDiagramEntity( self, operations, className )

            arguments
                self( 1, 1 )classdiagram.app.core.ElementCreator;
                operations( 1, 1 )diagram.interface.Operations;
                className( 1, 1 )string{ mustBeNonzeroLengthText };
            end



            classentity = self.App.findEntity( className );
            if isempty( classentity )
                return ;
            end
            factory = self.App.getClassDiagramFactory;
            class = factory.getNonCachedPackageElement( className );
            if isempty( class )
                return ;
            end


            subdiagram = classentity.subdiagram;
            fullExpandedState = self.getFullExpandedState( classentity );
            subentities = subdiagram.entities;
            for isubentity = 1:numel( subentities )
                subentity = subentities( isubentity );
                operations.destroy( subentity, true );
            end

            self.elementCreateUpdateHelper( operations, class );


            self.App.setExpandState( fullExpandedState );
        end

        function [ nlines, sectionLines, sectionNames ] =  ...
                createClassMembers( self, operations, options )
            arguments
                self( 1, 1 )classdiagram.app.core.ElementCreator;
                operations( 1, 1 )diagram.interface.Operations;
                options.Class( 1, 1 )classdiagram.app.core.domain.PackageElement;
                options.Entity( 1, 1 )diagram.interface.Entity;
                options.toCollapse( 1, 1 )logical = false;
            end
            factory = self.App.getClassDiagramFactory;
            if isfield( options, "Class" ) && ~isempty( options.Class )
                class = options.Class;
                classentity = self.App.findEntity( class.getName );
            elseif isfield( options, "Entity" ) && ~isempty( options.Entity )
                classentity = options.Entity;
                class = factory.getPackageElement( classentity.title );
            end
            if isempty( classentity ) || isempty( class )
                return ;
            end

            nlines = 0;
            sectionLines = struct;
            sectionNames = struct;

            function addSection( slines, sname )
                if ~isempty( slines )
                    sectionNames.( sname ) = slines( 1 );
                    sectionLines.( sname ) = slines( 2:end  );
                    nlines = nlines + size( slines, 2 );
                end
            end

            subdiagram = classentity.subdiagram;
            if isa( class, 'classdiagram.app.core.domain.Enum' )
                literals = factory.getEnumLiterals( class );
                lines = self.createDiagramEntityForClassMembers( operations, literals, "Values", "ValueTitle", subdiagram, options.toCollapse );
                addSection( lines, "Values" );
            end
            properties = factory.getProperties( class );
            lines = self.createDiagramEntityForClassMembers( operations, properties, "Properties", "PropertyTitle", subdiagram, options.toCollapse );
            self.addPropertyDomainTypeToTitle( operations, properties );
            addSection( lines, "Properties" );
            lines = self.createDiagramEntityForClassMembers( operations, factory.getMethods( class ), "Methods", "MethodTitle", subdiagram, options.toCollapse );
            addSection( lines, "Methods" );
            lines = self.createDiagramEntityForClassMembers( operations, factory.getEvents( class ), "Events", "EventTitle", subdiagram, options.toCollapse );
            addSection( lines, "Events" );
        end
    end
end



