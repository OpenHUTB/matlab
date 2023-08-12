function resetToDefaultValues( elem, stereotypeName )







psu = elem.getPropertySet( stereotypeName );
while ~isempty( psu )
for pu = psu.properties.toArray
pu.clearValue( elem.UUID );
end 
psu = psu.p_Parent;
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpsjjdPY.p.
% Please follow local copyright laws when handling this file.

