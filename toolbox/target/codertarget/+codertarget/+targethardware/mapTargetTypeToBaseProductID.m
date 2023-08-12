function out = mapTargetTypeToBaseProductID( in )

switch ( in )
case 0
out = codertarget.targethardware.BaseProductID.EC;
case 1
out = codertarget.targethardware.BaseProductID.SL;
case 2
out = codertarget.targethardware.BaseProductID.SLC;
otherwise 
out = codertarget.targethardware.BaseProductID.UNSPECIFIED;
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpRvYCHR.p.
% Please follow local copyright laws when handling this file.

