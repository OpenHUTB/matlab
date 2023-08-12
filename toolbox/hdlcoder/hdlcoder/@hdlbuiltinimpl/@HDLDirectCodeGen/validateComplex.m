function v = validateComplex( this, hC, inMsg, outMsg )























if ( nargin < 3 )

inMsg = message( 'hdlcoder:validate:UnsupportedDataTypeComplexOnInport' );
outMsg = message( 'hdlcoder:validate:UnsupportedDataTypeComplexOnOutport' );
elseif ( nargin < 4 )

outMsg = inMsg;
end 

ports = [  ];


for ii = 1:length( hC.SLInputPorts )
ports = [ ports, hC.SLInputPorts( ii ) ];
end 


v = this.baseValidateComplex( ports, inMsg );

if ( v.Status == 0 ) || ~( strcmp( inMsg.string, outMsg.string ) )


ports = [  ];


for ii = 1:length( hC.SLOutputPorts )
ports = [ ports, hC.SLOutputPorts( ii ) ];
end 


v = [ v, this.baseValidateComplex( ports, outMsg ) ];
end 





% Decoded using De-pcode utility v1.2 from file /tmp/tmpw3CTqm.p.
% Please follow local copyright laws when handling this file.

