function adapter = create( parentObj, name )




comp = parentObj.addComponent( name );
ports = comp.Architecture.addPort( { 'In', 'Out' }, { 'in', 'out' } );
ports( 1 ).connect( ports( 2 ) );
adapter = systemcomposer.utils.makeAdapter( comp );


% Decoded using De-pcode utility v1.2 from file /tmp/tmpaCpFyG.p.
% Please follow local copyright laws when handling this file.

