function tf = isUnspecifiedReferenceComponent( hdl )





tf = false;
if systemcomposer.internal.isReferenceComponent( hdl )
refName = systemcomposer.internal.getReferenceName( hdl );
tf = ~isvarname( refName );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpW847FC.p.
% Please follow local copyright laws when handling this file.

