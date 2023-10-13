classdef SwAddrMethodsTabAdapter < autosar.internal.dictionaryApp.tab.AbstractAutosarTabAdapter

    properties ( Constant, Access = protected )
        Category = 'SwAddrMethod';
        TabId = 'SwAddrMethodsTab';
    end

    properties ( Access = protected )
        DefaultEntryName = 'SwAddrMethod';
    end

    methods ( Static, Access = public )
        function columnNames = getColumnNames(  )
            columnNames = autosar.internal.dictionaryApp.node.SwAddrMethodsNode.getColumnNames(  );
        end
    end

    methods ( Access = public )
        function addEntry( this, ~ )
            swAddrMethodPackage = autosar.ui.metamodel.SwAddrMethod.getDefaultSwAddrMethodPackage(  ...
                this.M3IModel.RootPackage.front );
            this.AutosarAPIObj.addPackageableElement( 'SwAddrMethod', swAddrMethodPackage,  ...
                this.getDefaultEntryName(  ),  ...
                'SectionType', autosar.ui.metamodel.PackageString.DefaultSectionType );
        end

        function node = getNode( this, qualifiedName )
            m3iObj =  ...
                autosar.api.getAUTOSARProperties.findObjByPartialOrFullPath(  ...
                this.M3IModel, qualifiedName );
            node = autosar.internal.dictionaryApp.node.SwAddrMethodsNode( m3iObj );
        end

        function canPaste = canPaste( ~, node )

            canPaste =  ...
                isa( node, 'autosar.internal.dictionaryApp.node.SwAddrMethodsNode' );
        end
    end

    methods ( Access = protected )
        function addedEntry = addEntryForSourceObj( this, entryName, sourceObj )
            arguments
                this
                entryName{ mustBeNonzeroLengthText };
                sourceObj( 1, 1 )Simulink.metamodel.arplatform.common.SwAddrMethod;
            end
            swAddrMethodPackage = autosar.ui.metamodel.SwAddrMethod.getDefaultSwAddrMethodPackage(  ...
                this.M3IModel.RootPackage.front );
            this.AutosarAPIObj.addPackageableElement( 'SwAddrMethod', swAddrMethodPackage,  ...
                entryName, 'SectionType', sourceObj.SectionType.toString(  ) );
            addedEntry = [  ];
        end
    end
end


