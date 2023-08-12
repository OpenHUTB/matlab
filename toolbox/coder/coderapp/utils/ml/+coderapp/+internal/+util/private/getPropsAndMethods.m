



function result = getPropsAndMethods( className, mode, opts )
R36
className( 1, 1 )string
mode( 1, 1 )string{ mustBeMember( mode, [ "properties", "methods" ] ) }
opts.Access string = [ "public", "protected" ]
opts.Abstract( 1, 1 )logical
opts.Inherited( 1, 1 )logical
opts.Hidden( 1, 1 )logical
end 

mc = meta.class.fromName( className );
if isempty( mc )
result = {  };
return 
end 

switch mode
case "properties"
metas = mc.PropertyList;
case "methods"
metas = mc.MethodList;
end 

hasOpts = isfield( opts, { 
'Access'
'Abstract'
'Inherited'
'Hidden'
 } );

if hasOpts( 1 )
metas = filterByAccess( metas, opts.Access );
end 
if hasOpts( 2 )
metas( [ metas.Abstract ] ~= opts.Abstract ) = [  ];
end 
if hasOpts( 3 )
metas( ( mc == [ metas.DefiningClass ] ) == opts.Inherited ) = [  ];
end 
if hasOpts( 4 )
metas( [ metas.Hidden ] ~= opts.Hidden ) = [  ];
end 

result = { metas.Name };
end 


function result = filterByAccess( metas, accessFilter )
if isa( metas, 'meta.property' )
access = { metas.GetAccess };
else 
access = { metas.Access };
end 

select = true( size( metas ) );

hasList = cellfun( 'isclass', access, 'cell' );
select( ~hasList ) = ismember( access( ~hasList ), accessFilter );


if any( hasList )
for i = find( hasList )
list = [ access{ i }{ : } ];
select( i ) = any( strcmp( accessFilter, { list.Name } ) );
end 
end 

result = metas( select );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpO_WKZl.p.
% Please follow local copyright laws when handling this file.

