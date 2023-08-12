function out = query( container, names, values, options )



































R36
container
end 
R36( Repeating )
names string
values
end 
R36
options.Count = inf;
end 

found = 0;
out = [  ];

if isIterator( container )
while hasNext( container )
item = container.next(  );
if match( item, names, values )
found = found + 1;
out = [ out, item ];%#ok
if ( found >= options.Count )
return 
end 
end 
end 
else 
for i = 1:numel( container )
item = container( i );
if match( item, names, values )
found = found + 1;
out = [ out, item ];%#ok
if ( found >= options.Count )
return 
end 
end 
end 
end 
end 

function tf = match( obj, names, values )
tf = true;
for i = 1:numel( names )
if ~isequaln( obj.( names{ i } ), values{ i } )
tf = false;
return 
end 
end 
end 

function tf = isIterator( container )
tf = false;

if numel( container ) == 1
meta = metaclass( container );
n = numel( meta.MethodList );
for i = 1:n
if strcmp( { meta.MethodList.Name }, 'hasNext' )
tf = true;
return ;
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp7e9e_T.p.
% Please follow local copyright laws when handling this file.

