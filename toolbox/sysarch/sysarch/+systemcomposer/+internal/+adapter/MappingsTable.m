classdef MappingsTable < handle




    properties ( Access = private )
        Adapter;
        Inputs;
        Outputs;
        prevMappingTable;
    end
    properties
        numEntries;
    end
    methods
        function this = MappingsTable( adapter )

            arguments
                adapter( 1, 1 )double;
            end
            this.Adapter = adapter;
            [ this.Inputs, this.Outputs ] = systemcomposer.internal.adapter.getMappings( this.Adapter );
            this.prevMappingTable = this.getTableData(  );
        end
        function tableData = getTableData( this )

            tableData = [ this.Inputs, this.Outputs ];
        end
        function revert( this )

            this.Inputs = this.prevMappingTable( :, 1 );
            this.Outputs = this.prevMappingTable( :, 2 );
            this.prevMappingTable = [  ];
        end
        function save( this )

            this.prevMappingTable = this.getTableData(  );
            systemcomposer.internal.adapter.setMappings( this.Adapter, this.Inputs, this.Outputs );
        end
        function len = get.numEntries( this )
            len = length( this.Inputs );
        end
        function resetMappings( this )

            outBlk = find_system( this.Adapter, 'BlockType', 'Outport' );
            inBlk = find_system( this.Adapter, 'BlockType', 'Inport' );
            this.Inputs = { get_param( inBlk( 1 ), 'PortName' ) };
            this.Outputs = { get_param( outBlk( 1 ), 'PortName' ) };
            this.save(  );
        end
        function tf = isConsistent( this )

            tf = true;
            outBlk = find_system( this.Adapter, 'BlockType', 'Outport' );

            if isempty( outBlk ) ||  ...
                    ( length( this.Inputs ) ~= length( this.Outputs ) )

                tf = false;
            end

            if isempty( this.Inputs )


                for i = 1:length( outBlk )
                    lH = get_param( outBlk( i ), 'LineHandles' );
                    if ~isempty( lH.Inport ) && lH.Inport ~=  - 1 &&  ...
                            ( get_param( lH.Inport, "SrcBlockHandle" ) ~=  - 1 )

                        tf = false;
                    end
                end
            end
        end
        function removeMapping( this, row )

            arguments
                this;
                row( 1, : ){ mustBeInteger };
            end
            this.Inputs( row ) = [  ];
            this.Outputs( row ) = [  ];
        end
        function [ in, out ] = getMapping( this, row )

            arguments
                this;
                row( 1, 1 ){ mustBeInteger };
            end
            in = '';
            out = '';
            if row > 0 && row <= this.numEntries
                in = this.Inputs{ row };
                out = this.Outputs{ row };
            end
        end
        function addMapping( this, inputElem, outputElem )

            arguments
                this;
                inputElem( 1, : )char;
                outputElem( 1, : )char;
            end
            this.Inputs = [ this.Inputs;{ inputElem } ];
            this.Outputs = [ this.Outputs;{ outputElem } ];
        end
        function idx = hasInput( this, elem )

            arguments
                this;
                elem( 1, : )char
            end
            idx = strcmp( this.Inputs, elem );
        end
        function idx = hasOutput( this, elem )

            arguments
                this;
                elem( 1, : )char
            end
            idx = strcmp( this.Outputs, elem );
        end
        function idx = searchOutputs( this, searchText )


            arguments
                this;
                searchText( 1, : )char
            end
            idx = contains( this.Outputs, searchText );
        end
        function updateEntryName( this, type, oldName, newName )

            arguments
                this;
                type( 1, : )char;
                oldName( 1, : )char;
                newName( 1, : )char;
            end




            checkForExactMatch = true;
            if ~contains( oldName, '.' )
                checkForExactMatch = false;
                oldName = [ oldName, '.' ];
                newName = [ newName, '.' ];
            end

            if strcmp( type, 'input' )
                if checkForExactMatch
                    matchIdx = strcmp( oldName, this.Inputs );
                else
                    matchIdx = startsWith( this.Inputs, oldName );
                end
                toChange = this.Inputs( matchIdx );
                changed = replaceBetween( toChange, 1, length( oldName ), newName, 'Boundaries', 'Inclusive' );
                this.Inputs( matchIdx ) = changed;
            elseif strcmp( type, 'output' )
                if checkForExactMatch
                    matchIdx = strcmp( oldName, this.Outputs );
                else
                    matchIdx = startsWith( this.Outputs, oldName );
                end
                toChange = this.Outputs( matchIdx );
                changed = replaceBetween( toChange, 1, length( oldName ), newName, 'Boundaries', 'Inclusive' );
                this.Outputs( matchIdx ) = changed;
            else
            end
        end
    end
end
