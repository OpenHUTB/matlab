function v = validateVectorPorts( this, hC )





















ports = this.getAllSLInputPorts( hC );


msg = 'HDL code generation is not supported for vector inputs and outputs';
v = this.baseValidateVectorPorts( ports, 'message', msg );



% Decoded using De-pcode utility v1.2 from file /tmp/tmpMTPrf4.p.
% Please follow local copyright laws when handling this file.

