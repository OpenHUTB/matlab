classdef ClassDiagramIOModelBuilder

    properties
        mSyntax;
        mShowPackageNames( 1, 1 )logical = true;
        mShowDetails( 1, 1 )logical = false;
        mClassBrowser;
    end

    methods
        function obj = ClassDiagramIOModelBuilder( app )
            obj.mSyntax = app.syntax;
            obj.mShowPackageNames = app.getGlobalSetting( "ShowPackageNames" );
            obj.mShowDetails = app.getGlobalSetting( "ShowDetails" );
            obj.mClassBrowser = app.getClassBrowser(  );
        end

        function model = build( obj )
            import classdiagram.app.io.ClassDiagramIOModelBuilder;
            import classdiagram.app.core.domain.*;

            syntax = obj.mSyntax;

            CLASSTYPE = string( ClassDiagramTypes.typeMap( Class.ConstantType ) );
            ENUMTYPE = string( ClassDiagramTypes.typeMap( Enum.ConstantType ) );

            model = mf.zero.Model;

            diagram = syntax.root;
            entities = diagram.entities;

            diagInfo = classdiagram.io.DiagramInfo( model );
            diagInfo.domainName = "mcos";
            diagInfo.showPackageNames = obj.mShowPackageNames;
            diagInfo.showMixins = obj.mShowDetails;

            ioDiag = classdiagram.io.Diagram( model );

            for entity = entities'
                if entity.type == CLASSTYPE
                    ioCls = classdiagram.io.Class( model );
                    ioDiag.elements.add( ioCls );
                    ClassDiagramIOModelBuilder.fillEntity( ioCls, entity, model );
                elseif entity.type == ENUMTYPE
                    ioEnum = classdiagram.io.Enum( model );
                    ioDiag.elements.add( ioEnum );
                    ClassDiagramIOModelBuilder.fillEntity( ioEnum, entity, model );
                end
            end

            diagInfo.browserState = classdiagram.io.BrowserState( model );
            cb = obj.mClassBrowser;
            cbRoots = cb.getRootNodes;
            for iroot = 1:numel( cbRoots )
                root = cbRoots{ iroot };
                switch root.ConstantType
                    case "Package"
                        diagInfo.browserState.roots.add( classdiagram.io.BrowserRoot( model,  ...
                            struct( type = classdiagram.io.BrowserRootType.PACKAGE, identifier = root.getName ) ) );
                    case "Class"
                        diagInfo.browserState.roots.add( classdiagram.io.BrowserRoot( model,  ...
                            struct( type = classdiagram.io.BrowserRootType.CLASS, identifier = root.getName ) ) );
                    case "Enum"
                        diagInfo.browserState.roots.add( classdiagram.io.BrowserRoot( model,  ...
                            struct( type = classdiagram.io.BrowserRootType.ENUM, identifier = root.getName ) ) );
                    case "Folder"
                        diagInfo.browserState.roots.add( classdiagram.io.BrowserRoot( model,  ...
                            struct( type = classdiagram.io.BrowserRootType.FOLDER, identifier = root.getName ) ) );
                    case "Project"
                        diagInfo.browserState.roots.add( classdiagram.io.BrowserRoot( model,  ...
                            struct( type = classdiagram.io.BrowserRootType.PROJECT, identifier = root.getName ) ) );
                end
            end

        end
    end
    methods ( Static, Access = private )
        function has = hasMeta( metastring, prop, value )
            arguments
                metastring( 1, 1 )string;
                prop( 1, 1 )string;
                value( 1, 1 )string = "";
            end

            if isempty( value )
                checkstring = prop + "-" + prop;
            else
                checkstring = prop + "-" + value;
            end

            has = contains( metastring, checkstring );
        end

        function fillEntity( io, syn, model )
            import classdiagram.app.io.ClassDiagramIOModelBuilder;

            COLLAPSED = 'collapsed';

            io.name = syn.title;
            io.domainId = syn.getAttribute( 'ObjectID' ).value;
            if syn.hasAttribute( 'Metadata' )
                metadata = string( syn.getAttribute( 'Metadata' ).value );
                if ClassDiagramIOModelBuilder.hasMeta( metadata, "Abstract" )
                    io.abstract = true;
                end
                if ClassDiagramIOModelBuilder.hasMeta( metadata, "Hidden" )
                    io.hidden = true;
                end
            end

            ClassDiagramIOModelBuilder.setBounds( io, syn );
            if syn.hasAttribute( COLLAPSED )
                io.expanded = syn.getAttribute( COLLAPSED ).value ~= 1;
            end
            if syn.hasAttribute( 'SuperclassNames' ) && ~isempty( syn.getAttribute( 'SuperclassNames' ).value )
                for superclassName = split( syn.getAttribute( 'SuperclassNames' ).value, "," )'
                    io.superclassNames.add( superclassName{ : } );
                end
            end

            ClassDiagramIOModelBuilder.addItems( io, syn.subdiagram, model );
        end


        function addItems( io, container, model )
            import classdiagram.app.io.ClassDiagramIOModelBuilder;
            COLLAPSED = 'collapsed';

            section = [  ];
            for item = container.entities'
                if item.type == "subtitle"
                    section = classdiagram.io.Section( model, struct( 'name', item.title ) );
                    io.sections.add( section );
                else
                    if ~isempty( section )
                        lineItem = classdiagram.io.LineItem( model, struct( 'text', item.title ) );
                        lineItem.domainId = item.getAttribute( 'ObjectID' ).value;
                        names = split( lineItem.domainId, "$" );
                        lineItem.name = names{ 2 };
                        if item.hasAttribute( 'ValueType' )
                            lineItem.valueType = item.getAttribute( 'ValueType' ).value;
                        end
                        if item.hasAttribute( 'Metadata' )
                            metadata = string( item.getAttribute( 'Metadata' ).value );
                            if ClassDiagramIOModelBuilder.hasMeta( metadata, "access", "public" )
                                lineItem.access = classdiagram.io.Access.PUBLIC;
                            elseif ClassDiagramIOModelBuilder.hasMeta( metadata, "access", "private" )
                                lineItem.access = classdiagram.io.Access.PRIVATE;
                            elseif ClassDiagramIOModelBuilder.hasMeta( metadata, "access", "readonly" )
                                lineItem.access = classdiagram.io.Access.READONLY;
                            elseif ClassDiagramIOModelBuilder.hasMeta( metadata, "access", "immutable" )
                                lineItem.access = classdiagram.io.Access.IMMUTABLE;
                            end

                            if ClassDiagramIOModelBuilder.hasMeta( metadata, "Static" )
                                lineItem.static = true;
                            end

                            if ClassDiagramIOModelBuilder.hasMeta( metadata, "Hidden" )
                                lineItem.hidden = true;
                            end

                            if ClassDiagramIOModelBuilder.hasMeta( metadata, "Abstract" )
                                lineItem.abstract = true;
                            end
                        end
                        if item.hasAttribute( COLLAPSED )
                            section.expanded = item.getAttribute( COLLAPSED ).value ~= 1;
                        end
                        section.items.add( lineItem );
                    end
                end
            end
        end

        function setBounds( io, syn )
            io.bounds.left = syn.getPosition.x;
            io.bounds.top = syn.getPosition.y;
            io.bounds.width = syn.getSize.width;
            io.bounds.height = syn.getSize.height;
        end
    end
end


