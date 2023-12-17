classdef ( Abstract )NonTerminalNode < matlabshared.devicetree.node.NodeBase

    properties ( SetAccess = protected )

        Label string

        Properties matlabshared.devicetree.property.PropertyBase

        ChildNodes matlabshared.devicetree.node.NodeBase
    end

    properties ( Dependent, Access = protected )

        PropertyNames

        ChildNodeNames
    end

    properties ( Hidden, SetAccess = protected )
        Alias string
    end


    properties ( SetAccess = protected )

        UnitAddress double

        AddressLength double
    end

    properties ( Dependent, Hidden )

        AddressCells double

        SizeCells double

        RequiredAddressCells double

        RequiredSizeCells double
    end


    properties ( Constant, Access = protected )
        AddressCellsPropName = "#address-cells";

        SizeCellsPropName = "#size-cells";
    end


    methods
        function obj = NonTerminalNode( name, label, options, addressOptions )

            arguments
                name string
                label string = string.empty;
                options.Alias string
            end


            arguments
                addressOptions.UnitAddress( :, : )double = [  ];
                addressOptions.AddressLength( :, : )double = [  ];
            end

            unitAddr = addressOptions.UnitAddress;
            addrLen = addressOptions.AddressLength;


            if ~isempty( addressOptions.UnitAddress )
                hexAddrStr = compose( "%X", unitAddr( 1, : ) );
                name = name + "@" + join( hexAddrStr, "," );
            end

            obj = obj@matlabshared.devicetree.node.NodeBase( name );
            obj.Label = label;

            if isfield( options, "Alias" )
                error( 'Aliases not supported yet.' );

            end

            obj.UnitAddress = unitAddr;
            obj.AddressLength = addrLen;

            if ~isempty( obj.AddressLength ) && ( size( obj.UnitAddress, 1 ) ~= size( obj.AddressLength, 1 ) )
                error( message( 'devicetree:base:InvalidAddressLength' ) );
            end

            if ~isempty( obj.UnitAddress )
                regValue = [ obj.UnitAddress, obj.AddressLength ]';
                obj.addProperty( "reg", num2cell( regValue( : )' ) );
            end
        end
    end


    methods
        function nameList = get.PropertyNames( obj )
            if isempty( obj.Properties )
                nameList = string.empty;
            else
                nameList = [ obj.Properties.Name ];
            end
        end

        function nameList = get.ChildNodeNames( obj )
            if isempty( obj.ChildNodes )
                nameList = string.empty;
            else
                nameList = [ obj.ChildNodes.Name ];
            end
        end

        function numCells = get.AddressCells( obj )
            try
                numCells = cell2mat( obj.getPropertyValue( obj.AddressCellsPropName ) );
            catch
                numCells = [  ];
            end
        end

        function numCells = get.SizeCells( obj )
            try
                numCells = cell2mat( obj.getPropertyValue( obj.SizeCellsPropName ) );
            catch
                numCells = [  ];
            end
        end

        function set.AddressCells( obj, numCells )
            if isempty( obj.AddressCells )
                obj.addProperty( obj.AddressCellsPropName, { numCells } );
            else
                obj.setPropertyValue( obj.AddressCellsPropName, { numCells } );
            end
        end

        function set.SizeCells( obj, numCells )
            if isempty( obj.SizeCells )
                obj.addProperty( obj.SizeCellsPropName, { numCells } );
            else
                obj.setPropertyValue( obj.SizeCellsPropName, { numCells } );
            end
        end

        function numCells = get.RequiredAddressCells( obj )


            numCells = size( obj.UnitAddress, 2 );
        end

        function numCells = get.RequiredSizeCells( obj )



            numCells = size( obj.AddressLength, 2 );
        end
    end


    methods ( Hidden )
        function hasAny = hasChildNodes( obj )

            hasAny = ~isempty( obj.ChildNodes );
        end

        function hasAny = hasProperties( obj )

            hasAny = ~isempty( obj.Properties );
        end

        function isAddressable = isAddressableNode( obj )

            isAddressable = ~isempty( obj.UnitAddress );
        end
    end


    methods
        function hProp = addProperty( obj, prop, varargin )

            if isa( prop, 'matlabshared.devicetree.property.PropertyBase' )
                hProp = prop;
            else
                hProp = matlabshared.devicetree.property.Property( prop, varargin{ : } );
            end
            obj.addPropertyObject( hProp );
        end

        function hProp = addPropertyDeletion( obj, name )

            hProp = matlabshared.devicetree.property.DeleteProperty( name );
            obj.addPropertyObject( hProp );
        end

        function hNode = addNode( obj, node, varargin )

            if isa( node, 'matlabshared.devicetree.node.NodeBase' )
                hNode = node;
            else
                hNode = matlabshared.devicetree.node.Node( node, varargin{ : } );
            end

            obj.addNodeObject( hNode );
        end

        function hNode = addNodeDeletion( obj, name )

            hNode = matlabshared.devicetree.node.DeleteNode( name );
            obj.addNodeObject( hNode );
        end
    end

    methods ( Hidden )
        function hNode = addEmptyNode( obj )

            hNode = matlabshared.devicetree.node.EmptyNode(  );
            obj.addNodeObject( hNode );
        end


        function removeProperty( obj, propName )

            propNameIdx = ismember( obj.PropertyNames, propName );
            obj.Properties( propNameIdx ) = [  ];
        end

        function hProp = getProperty( obj, propName )

            propNameIdx = ismember( obj.PropertyNames, propName );
            hProp = obj.Properties( propNameIdx );
        end

        function propVal = getPropertyValue( obj, propName )

            hProp = obj.getProperty( propName );
            if isempty( hProp )
                error( message( 'devicetree:base:InvalidPropertyName', propName, obj.Name ) );
            end

            propVal = hProp.Value;
        end


        function setPropertyValue( obj, propName, varargin )

            hProp = obj.getProperty( propName );
            if isempty( hProp )
                error( message( 'devicetree:base:InvalidPropertyName', propName, obj.Name ) );
            end

            hPropNew = matlabshared.devicetree.property.Property( propName, varargin{ : } );

            propNameIdx = ismember( obj.PropertyNames, propName );
            obj.Properties( propNameIdx ) = hPropNew;
        end


        function removeNode( obj, nodeName )

            nodeNameIdx = ismember( obj.ChildNodeNames, nodeName );

            obj.ChildNodes( nodeNameIdx ).removeParentNode;

            obj.ChildNodes( nodeNameIdx ) = [  ];
        end

        function hNode = getNode( obj, nodeName )

            nodeNameIdx = ismember( obj.ChildNodeNames, nodeName );
            hNode = obj.ChildNodes( nodeNameIdx );
        end
    end

    methods ( Access = protected )

        function addPropertyObject( obj, hProp )

            if ismember( hProp.Name, obj.PropertyNames )
                error( message( 'devicetree:base:DuplicatePropertyName', hProp.Name, obj.Name ) );
            end

            obj.Properties( end  + 1 ) = hProp;
        end


        function addNodeObject( obj, hNode )

            if hNode.isAddressableNode

                if ~isempty( obj.AddressCells ) && ( hNode.RequiredAddressCells ~= obj.AddressCells )
                    error( message( 'devicetree:base:NodeCellsMismatch', hNode.Name, hNode.RequiredAddressCells, obj.AddressCellsPropName, obj.Name, obj.AddressCells ) );
                end
                if ~isempty( obj.SizeCells ) && ( hNode.RequiredSizeCells ~= obj.SizeCells )
                    error( message( 'devicetree:base:NodeCellsMismatch', hNode.Name, hNode.RequiredSizeCells, obj.SizeCellsPropName, obj.Name, obj.SizeCells ) );
                end

            end

            if ismember( hNode.Name, obj.ChildNodeNames )
                error( message( 'devicetree:base:DuplicateNodeName', hNode.Name, obj.Name ) );
            end

            if ~hNode.allowsParentNode
                error( message( 'devicetree:base:InvalidChildNode', hNode.Name ) );
            end

            if hNode == obj
                error( message( 'devicetree:base:InvalidChildNodeLoop', obj.Name ) );
            end

            if ~isempty( hNode.ParentNode )
                error( message( 'devicetree:base:ExistingParentNode', hNode.Name, obj.Name, hNode.ParentNode.Name ) );
            end

            hNode.ParentNode = obj;


            obj.ChildNodes( end  + 1 ) = hNode;
        end
    end


    methods ( Hidden )
        function refName = getReferenceName( obj )
            if ~isempty( obj.Label )

                refName = "&" + obj.Label;
            else

                refName = "&{" + obj.getNodePath + "}";
            end
        end
    end

    methods ( Abstract, Hidden )

        nodePath = getNodePath( obj )
    end


    methods ( Access = protected )
        function printBody( obj, hDTPrinter, isOverlay, ~ )

            if isOverlay

                hTargetNode = obj.getOverlayTargetNode;

                if ~isempty( hTargetNode.Label )
                    targetLine = "target";
                    targetReference = "<" + hTargetNode.getReferenceName + ">";
                else
                    targetLine = "target-path";
                    targetReference = """" + hTargetNode.getNodePath + """";
                end

                targetLine = targetLine + " = " + targetReference + ";";
                hDTPrinter.addLine( targetLine );
                hDTPrinter.addLine( "__overlay__ {" );
                hDTPrinter.indent;
            else

                startNodeLine = obj.getSourceLabelPrefix;
                startNodeLine = startNodeLine + obj.Name + " {";

                hDTPrinter.addLine( startNodeLine );
                hDTPrinter.indent;
            end

            for hProp = obj.Properties
                hProp.printObject( hDTPrinter );
            end

            for hNode = obj.ChildNodes
                hNode.printObject( hDTPrinter );
            end

            hDTPrinter.unindent;
            hDTPrinter.addLine( "};" );
        end
    end

    methods ( Abstract, Access = protected )

        hTargetNode = getOverlayTargetNode( obj )

        labelPrefix = getSourceLabelPrefix( obj )
    end


    methods ( Static, Access = protected )
        function validateNodeName( name )
        end

        function validateNodeLabel( label )
        end

        function validateNodeAlias( alias )
        end
    end

end

