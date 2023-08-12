function retVal = getNonVirtualSystem( system )





parentSys = get_param( system, 'Parent' );
if isempty( parentSys )
retVal = system;
else 
if strcmp( get_param( system, 'IsSubsystemVirtual' ), 'on' )
retVal = getNonVirtualSystem( parentSys );
else 
retVal = system;
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpGjIj7v.p.
% Please follow local copyright laws when handling this file.

