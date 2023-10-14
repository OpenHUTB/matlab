function resources = parseResourcesFromReport( fileName, target )

arguments
    fileName
    target( 1, 1 )string{ mustBeMember( target, [ "Intel", "Xilinx" ] ) }
end

if strcmp( target, 'Xilinx' )
    areaStrings = { 'LUTs', 'Block RAM Tile   ', 'DSPs' };
elseif strcmp( target, 'Intel' )
    areaStrings = { 'utilization', 'block memory bits', 'RAM', 'DSP' };
end
resources = [  ];


fid = fopen( fileName );
cleanup = onCleanup( @(  )fclose( fid ) );

tline = fgetl( fid );

while ischar( tline )
    for i = 1:length( areaStrings )
        str = areaStrings{ i };

        k = strfind( tline, str );

        if ( k )
            if strcmp( target, 'Intel' )
                tline = erase( tline, ',' );
            end
            info = str2double( regexp( tline, '[\d]+\.?[\d]*', 'match' ) );
            if strcmp( target, 'Xilinx' )
                info( :, 2 ) = [  ];
            end

            if strcmp( str, 'LUTs' ) || strcmp( str, 'utilization' )
                resources.LUT = [ info( 1 ), info( 2 ) ];
            elseif strcmp( str, 'Block RAM Tile   ' ) || strcmp( str, 'RAM' )
                resources.BlockRAM = [ info( 1 ), info( 2 ) ];
            elseif strcmp( str, 'DSPs' ) || strcmp( str, 'DSP' )
                resources.DSP = [ info( 1 ), info( 2 ) ];
            elseif strcmp( str, 'block memory bits' )
                resources.BlockMemoryBits = [ info( 1 ), info( 2 ) ];
            end
        end
    end

    tline = fgetl( fid );
end
end


