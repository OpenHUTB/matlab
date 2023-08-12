function printLog = simprintlog( systems, resolved, unresolved )













spc = blanks( 2 );
returnChar = sprintf( '\n' );




sysLog = cell( length( systems ), 1 );
for i = 1:length( systems ), 
obj = systems( i );

if isa( obj, 'Simulink.Object' )
SFHdr = '      ';
else 
SFHdr = ' (SF) ';
end 
path = obj.getFullName(  );
path( path == returnChar ) = ' ';
sysLog{ i, 1 } = [ sprintf( '%6d', i ), SFHdr, path ];
end 


sysLog = char( sysLog );
if ~isempty( sysLog ), 
sysTitle = [ '  Page', blanks( length( SFHdr ) ), 'System Name' ];
sysWidth = max( size( sysLog, 2 ), size( sysTitle, 2 ) );
banner = '-';
banner = banner( 1, ones( 1, sysWidth ) );
sysLog = char( sysTitle, banner, sysLog, '', '' );
end 




resolvedLog = cell( length( resolved ), 1 );
for i = 1:length( resolved ), 
obj = resolved( i );

if isa( obj, 'Simulink.Object' )
SFHdr = '      ';
else 
SFHdr = ' (SF) ';
end 

refPages = [  ];
refNames = {  };

for j = 1:length( systems )
sys = systems( j );
if isa( sys, 'Stateflow.Chart' )
h = sfprivate( 'chart2block', sys.Id );
if ~isempty( h )
sys = get_param( h, 'Object' );
end 
end 
r = sys.find( '-depth', 1, 'ReferenceBlock', obj.getFullName );
for x = 1:length( r )
refPages = [ refPages, j ];%#ok<AGROW>
name = r( x ).name;
name( name == returnChar ) = ' ';
refNames{ end  + 1 } = name;%#ok<AGROW>
end 
end 

if ~isempty( refPages )
xReferences = {  };
for lp = 1:length( refPages )
xReferences{ lp, 1 } = [ blanks( 4 ), spc, '  (', sprintf( '%3d', refPages( lp ) ) ...
, spc, refNames{ lp }, ')' ];%#ok<AGROW>
end 

path = obj.getFullName(  );
path( path == returnChar ) = ' ';
xReferences = char( xReferences );
resolvedLog{ i, 1 } =  ...
char( '', [ sprintf( '%6d', length( systems ) + i ), SFHdr, path ], xReferences );
end 
end 


resolvedLog = char( resolvedLog );
if ~isempty( resolvedLog ), 
resolvedTitle =  ...
char( [ '  Page', blanks( length( SFHdr ) ) ...
, 'Unique Resolved Library Links' ],  ...
[ blanks( 4 ), spc, '  (Page and Block Name referencing link)' ] );
resolvedWidth = max( size( resolvedLog, 2 ), size( resolvedTitle, 2 ) );
banner = '-';
banner = banner( 1, ones( 1, resolvedWidth ) );
resolvedLog = char( resolvedTitle, banner, resolvedLog, '', '' );
end 





unique = containers.Map;
for i = 1:length( unresolved )
r = unresolved( i );
sb = r.SourceBlock;
if unique.isKey( sb )
v = unique( sb );
unique( sb ) = vertcat( v, r );
else 
unique( sb ) = r;
end 
end 

keys = unique.keys;
vals = unique.values;
unresolvedLog = cell( length( keys ), 1 );

for i = 1:length( keys )
v = cell2mat( vals( i ) );
SFHdr = '      ';
xReferences = {  };
for j = 1:length( v )
p = get_param( v( j ).parent, 'object' );
if slprivate( 'is_stateflow_based_block', p.handle )
c = sfprivate( 'block2chart', p.handle );
if ~isempty( c )
p = find( sfroot, 'Id', c );
end 
end 

name = v( j ).name;
o = p.find( 'name', v( j ).name );
if isa( o, 'Stateflow.Object' )
SFHdr = ' (SF) ';
end 

name( name == returnChar ) = ' ';
xReferences{ j, 1 } = [ blanks( 4 ), spc, '  (', sprintf( '%3d', find( systems == p ) ) ...
, spc, name, ')' ];%#ok<AGROW>
end 
path = cell2mat( keys( i ) );
path( path == returnChar ) = ' ';
xReferences = char( xReferences );
unresolvedLog{ i, 1 } =  ...
char( '', [ sprintf( '%6d', length( systems ) + i ), SFHdr, path ], xReferences );
end 


unresolvedLog = char( unresolvedLog );
if ~isempty( unresolvedLog ), 
unresolvedTitle = { 
'(  Not         Unique Unresolved Library Links'
' Printed)        (Page and System Name referencing link)'
 };
unresolvedTitle = char( unresolvedTitle{ : } );

unresolvedWidth = max( size( unresolvedLog, 2 ), size( unresolvedTitle, 2 ) );
banner = '-';
banner = banner( 1, ones( 1, unresolvedWidth ) );
unresolvedLog = char( unresolvedTitle, banner, unresolvedLog );
end 



printLog = char( sysLog,  ...
resolvedLog,  ...
unresolvedLog ...
 );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpYjd50p.p.
% Please follow local copyright laws when handling this file.

