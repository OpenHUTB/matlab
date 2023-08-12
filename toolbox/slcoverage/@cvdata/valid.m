function out = valid( cvdata )






out = false;
if cvdata.isInvalidated
return ;
end 

if ~cvdata.isLoaded
cvdata.load(  );
end 

id = cvdata.id;

if ( id ~= 0 ) &&  ...
( ~cv( 'ishandle', id ) || cv( 'get', id, '.isa' ) ~= cv( 'get', 'default', 'testdata.isa' ) )
return ;
end 

out = validRoot( cvdata );




% Decoded using De-pcode utility v1.2 from file /tmp/tmpNQF6qt.p.
% Please follow local copyright laws when handling this file.

