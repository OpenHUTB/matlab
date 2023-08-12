function plugrdInfo = readPluginrd( plugrdInfo )



ipcore = plugrdInfo.ipName;


fid = fopen( fullfile( plugrdInfo.prj_dir, 'system_bd.tcl' ), 'r' );
str = textscan( fid, '%s', 'Delimiter', '\n' );

interfaces = {  };
segLine = find( cellfun( @( x )contains( x, ipcore ) ...
 && contains( x, 'hsb_connect' ) && ~contains( x, 'clkgen' ) && ~contains( x, 'clk' ) ...
 && ~contains( x, 'rstgen' ), str{ 1 } ) );
for ii = 1:numel( segLine )
temp = extractAfter( str{ 1 }( segLine( ii ) ), 'hsb_connect ' );
intr1 = regexprep( extractAfter( temp, ' ' ), '[\W]*', '_' );
intr2 = regexprep( extractBefore( temp, ' ' ), '[\W]*', '_' );
interfaces = [ interfaces, intr1, intr2 ];
end 
uintr = unique( interfaces );
intrIdx = find( cellfun( @( x )~contains( x, 'LED' ) && ~contains( x, 'Slave' ) ...
 && ~contains( x, 's_axis' ) && ~contains( x, 'AXI4_Lite' ), uintr ) );
delIPcoreIntr = '';
for ii = 1:numel( intrIdx )
delIPcoreIntr = [ delIPcoreIntr, ' ', uintr{ intrIdx( ii ) } ];
end 
plugrdInfo.numIntrPort = num2str( numel( intrIdx ) );
plugrdInfo.delIPcoreIntr = delIPcoreIntr;
plugrdInfo.exptclPath = regexprep( soc.internal.makeAbsolutePath( fullfile( plugrdInfo.exportDirectory, 'design_1.tcl' ) ), '\', '/' );


connectionLine = [ 'hsb_connect ', ipcore, '/AXI4_Lite' ];
LineIdx = find( cellfun( @( x )contains( x, connectionLine ), str{ 1 } ) );
Line = str{ 1 }( LineIdx );
plugrdInfo.AXI4Lite.InterfaceConnection = extractAfter( Line, 'AXI4_Lite ' );


segLine = find( cellfun( @( x )contains( x, [ 'set seg_name [get_bd_addr_segs -of [get_bd_intf_pins -of [get_bd_intf_nets  -of [get_bd_intf_pins ', ipcore, '/AXI4_Lite' ] ), str{ 1 } ) );
master.Name = {  };
master.SpaceName = {  };
for i = 1:numel( segLine )
newStr = extractAfter( str{ 1 }( segLine( i ) + 2 ), 'get_bd_intf_pins ' );
master.Name = [ master.Name, newStr{ 1 }( 1:end  - 2 ) ];
end 
plugrdInfo.AXI4Lite.MasterAddressSpace = [ '{', strjoin( master.Name, ' ,' ), '}' ];


if ( isfield( plugrdInfo, 'AXI_Master' ) )
axiMstIntrLine = find( cellfun( @( x )contains( x, ipcore ) ...
 && contains( x, 'hsb_connect' ) && ~contains( x, 'clkgen' ) ...
 && ~contains( x, 'rstgen' ) && contains( x, 'AXI4_Master' ) ...
 && ~contains( x, 'AXI4_Lite' ), str{ 1 } ) );
for ii = 1:numel( axiMstIntrLine )
temp = extractAfter( str{ 1 }( axiMstIntrLine( ii ) ), 'hsb_connect ' );
intr1 = regexprep( extractAfter( temp, ' ' ), '[\W]*', '/' );
intr2 = regexprep( extractBefore( temp, ' ' ), '[\W]*', '/' );
if ( mod( find( cellfun( @( x )contains( x, ipcore ), { intr1, intr2 } ) ), 2 ) == 0 )
mstIdx = str2num( string( extractAfter( intr2, [ ipcore, '/AXI4_Master_' ] ) ) ) + 1;
plugrdInfo.AXI_Master( mstIdx ).MstrChnlCon = intr1{ 1 };
else 
mstIdx = str2num( string( extractAfter( intr1, [ ipcore, '/AXI4_Master_' ] ) ) ) + 1;
plugrdInfo.AXI_Master( mstIdx ).MstrChnlCon = intr2{ 1 };
end 
end 
end 

fid1 = fopen( fullfile( plugrdInfo.prj_dir, 'read_bd.tcl' ), 'a' );
fprintf( fid1, 'set numIntrDutPorts %s\n', plugrdInfo.numIntrPort );
fprintf( fid1, 'set delIPcoreIntr [list %s]\n', plugrdInfo.delIPcoreIntr );
fprintf( fid1, 'set exptclPath %s\n', plugrdInfo.exptclPath );
fclose( fid1 );
fclose( fid );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpGbTODH.p.
% Please follow local copyright laws when handling this file.

