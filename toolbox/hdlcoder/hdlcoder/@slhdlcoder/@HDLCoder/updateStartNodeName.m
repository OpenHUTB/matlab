function updateStartNodeName( this, snn )


if isempty( snn ) || ~ischar( snn )
error( message( 'hdlcoder:engine:invalidmodelname' ) );
end 


this.updateCLI( 'HDLSubsystem', snn );
this.setModelName( bdroot( snn ) );

this.createConnection( snn );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmprTPeVe.p.
% Please follow local copyright laws when handling this file.

