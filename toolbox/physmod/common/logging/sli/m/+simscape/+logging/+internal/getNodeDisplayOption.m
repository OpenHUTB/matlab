function res = getNodeDisplayOption( node, name, default )




R36
node simscape.logging.Node{ mustBeNonempty }
name( 1, 1 )string
default
end 

res = simscape.logging.internal.getNodeDisplayOptions( node, name, { default } );
res = res{ 1 };

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpf4GUgV.p.
% Please follow local copyright laws when handling this file.

