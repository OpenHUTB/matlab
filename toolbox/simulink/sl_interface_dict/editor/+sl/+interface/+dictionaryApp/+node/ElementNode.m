classdef ( Abstract )ElementNode < sl.interface.dictionaryApp.node.DesignNode

    properties ( Access = private )
        Parent;
    end

    methods ( Access = public )
        function this = ElementNode( interfaceDictObj, parent, dictObj, platformKind, studio )
            this = this@sl.interface.dictionaryApp.node.DesignNode(  ...
                interfaceDictObj, dictObj, platformKind, studio );
            this.Parent = parent;
        end

        function dataObj = getDataObject( this )
            slddEntry = this.DictObj.getDDEntryObject( this.InterfaceDictElement.Owner.Name );
            entryValue = slddEntry.getValue(  );
            dataObj = entryValue.Elements( strcmp( { entryValue.Elements.Name },  ...
                this.InterfaceDictElement.Name ) );
        end

        function typeEditorObj = getTypeEditorObject( this, namedArgs )

            arguments
                this
                namedArgs.RefreshTypeEditorObject = false;
            end

            if isempty( this.TypeEditorObject ) || namedArgs.RefreshTypeEditorObject
                typeEditorParent = this.Parent.getTypeEditorObject( RefreshTypeEditorObject = namedArgs.RefreshTypeEditorObject );
                this.TypeEditorObject = sl.interface.dictionaryApp.node.typeeditor.ElementAdapter(  ...
                    this, typeEditorParent, this.getStudio(  ) );


                this.TypeEditorObject.UDTAssistOpen = this.UDTAssistOpen;
                this.TypeEditorObject.UDTIPOpen = this.UDTIPOpen;
            end
            assert( ~isempty( this.TypeEditorObject ),  ...
                'Did not construct TypeEditor object' );
            this.TypeEditorObject.IsBus = startsWith(  ...
                this.TypeEditorObject.getPropValue( 'DataType' ), 'Bus:' );


            typeEditorObj = this.TypeEditorObject;
        end

        function parentNode = getParentNode( this )
            parentNode = this.Parent;
        end

        function propValue = getPropValue( this, propName )

            propName = this.getRealPropName( propName );
            if strcmp( propName,  ...
                    sl.interface.dictionaryApp.node.PackageString.NameProp )
                propValue = this.getDisplayLabel(  );
            else
                if this.isPlatformProperty( propName )
                    propValue = getPropValue@sl.interface.dictionaryApp.node.DesignNode( this, propName );
                else
                    typeEditorObj = this.getTypeEditorObject(  );
                    if ~typeEditorObj.isReadonlyProperty( propName )
                        propValue = typeEditorObj.getPropValue( propName );
                    else
                        propValue = '';
                    end
                end
            end
        end

        function setPropValue( this, propName, propValue )


            propName = this.getRealPropName( propName );
            if this.isPlatformProperty( propName ) || strcmp( propName,  ...
                    sl.interface.dictionaryApp.node.PackageString.NameProp )
                setPropValue@sl.interface.dictionaryApp.node.DesignNode( this, propName, propValue );
            else


                studioApp = this.getStudio(  );
                cleanupObj = studioApp.disableSLDDListener(  );%#ok

                refreshTypeEditorObject = false;
                if ~isempty( this.TypeEditorObject )


                    refreshTypeEditorObject = ~strcmp( this.getParentNode.Name, this.TypeEditorObject.Parent.Name );
                end
                typeEditorObj = this.getTypeEditorObject( RefreshTypeEditorObject = refreshTypeEditorObject );
                typeEditorObj.setPropValue( propName, propValue );
            end
        end

        function isReadOnly = isReadonlyProperty( this, propName )

            typeEditorObj = this.getTypeEditorObject(  );
            realPropName = this.getRealPropName( propName );
            isReadOnly = typeEditorObj.isReadonlyProperty( realPropName );
        end

        function allowed = isDragAllowed( this )%#ok<MANU>

            allowed = true;
        end

        function allowed = isDropAllowed( this )%#ok<MANU>

            allowed = true;
        end

        function moveInParent( this, numPlaces )
            parentNode = this.getParentNode(  );
            parentBus = parentNode.getDataObject(  );
            sourceIdx = find( strcmp( this.Name, { parentBus.Elements.Name } ) );
            tmpElements = parentBus.Elements;


            destinationIdx = sourceIdx + numPlaces;
            if numPlaces > 0

                tmpElements( sourceIdx:destinationIdx - 1 ) =  ...
                    tmpElements( sourceIdx + 1:destinationIdx );
            elseif numPlaces < 0

                tmpElements( destinationIdx + 1:sourceIdx ) =  ...
                    tmpElements( destinationIdx:sourceIdx - 1 );
            else
                assert( false, 'Unexpected move' )
            end

            tmpElements( destinationIdx ) = this.getDataObject(  );
            parentBus.Elements = tmpElements;

            this.DictObj.setDDEntryValue( parentNode.Name, parentBus );
        end

        function copyTo( this, destinationParent, destinationIdx )

            copiedElement = this.getDataObject(  );

            destinationBus = destinationParent.getDataObject(  );


            copiedElement.Name =  ...
                sl.interface.dictionaryApp.utils.getUniqueName(  ...
                copiedElement.Name, { destinationBus.Elements.Name } );
            tmpElements = destinationBus.Elements;
            numElementsInDestination = length( tmpElements );

            tmpElements( destinationIdx ) = copiedElement;
            if destinationIdx <= numElementsInDestination
                tmpElements( destinationIdx + 1:numElementsInDestination + 1 ) =  ...
                    destinationBus.Elements( destinationIdx:end  );
            else

            end

            assert( length( tmpElements ) == length( destinationBus.Elements ) + 1,  ...
                'Copy did not create correct number of elements' )
            destinationBus.Elements = tmpElements;

            this.DictObj.setDDEntryValue( destinationParent.Name, destinationBus );

            source = this.InterfaceDictElement;



            destinationElements = destinationParent.InterfaceDictElement.Elements;
            destElementIdx = find( strcmp( copiedElement.Name, { destinationElements.Name } ) );
            destination = destinationParent.InterfaceDictElement.Elements( destElementIdx );
            if this.hasPlatformProperties(  ) &&  ...
                    isa( source, class( destination ) )

                sl.interface.dictionaryApp.utils.copyPlatformProperties( this.DictObj,  ...
                    source, destination );
            end
        end
    end

    methods ( Access = protected )
        function dlgSchema = customizeDialogSchema( this, dlgSchema )
            dlgSchema = this.adjustDialogSource( dlgSchema );
            dlgSchema = this.customizeAvailableDataTypes( dlgSchema );
        end
    end

    methods ( Access = private )

        function dlgSchema = adjustDialogSource( this, dlgSchema )
            assert( strcmp( dlgSchema.Items{ 1 }.Items{ 2 }.Items{ 2 }.Tag, 'DataType' ),  ...
                'Unexpected data type widget' )
            dlgSchema.Items{ 1 }.Items{ 2 }.Items{ 2 }.Source = this;
        end

        function dlgSchema = customizeAvailableDataTypes( ~, dlgSchema )

            assert( strcmp( dlgSchema.Items{ 1 }.Items{ 2 }.Items{ 2 }.Tag, 'DataType' ),  ...
                'Unexpected widget for datatypes' );
            availableDataTypes = dlgSchema.Items{ 1 }.Items{ 2 }.Items{ 2 }.Entries;
            if ~any( startsWith( availableDataTypes, 'Bus:' ) )
                refreshIdx = find( startsWith( availableDataTypes,  ...
                    DAStudio.message( 'Simulink:DataType:RefreshDataTypeInWorkspace' ) ) );
                availableDataTypes = [ availableDataTypes( 1:refreshIdx - 1 ) ...
                    , { 'Bus: <object name>' }, availableDataTypes( refreshIdx:end  ) ];
            end
            dlgSchema.Items{ 1 }.Items{ 2 }.Items{ 2 }.Entries = availableDataTypes;
        end
    end

    methods ( Access = public, Hidden )
        function getPropertyStyle( this, propName, propStyleObj )
            typeEditorObj = this.getTypeEditorObject(  );
            typeEditorObj.getPropertyStyle( propName, propStyleObj );
        end
    end
end


