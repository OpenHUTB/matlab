function valWithType = getValueWithType( value, pirType, sameDimsAsPirType )



if ( nargin < 3 )
sameDimsAsPirType = true;
end 

if ( nargin < 2 )
pirType = pir_double_t;
end 

if ( nargin < 1 )
value = 1;
end 

rndMode = 'Nearest';
satMode = 'Saturate';

valWithType = pirelab.getTypeInfoAsFi( pirType, rndMode, satMode, value, sameDimsAsPirType );
% Decoded using De-pcode utility v1.2 from file /tmp/tmpf9kTFf.p.
% Please follow local copyright laws when handling this file.

