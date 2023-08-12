function retVal = isParentArchitectureDomain( cbinfo, subDomain )



R36
cbinfo
subDomain = ''
end 

ownerGraphHandle = SLStudio.Utils.getDiagramHandle( cbinfo );
ownerGraphDomain = get_param( ownerGraphHandle, 'SimulinkSubDomain' );
if isempty( subDomain )
retVal = strcmp( ownerGraphDomain, 'AUTOSARArchitecture' ) ||  ...
strcmp( ownerGraphDomain, 'Architecture' ) ||  ...
strcmp( ownerGraphDomain, 'SoftwareArchitecture' );
else 
retVal = strcmp( ownerGraphDomain, subDomain );
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpb888Gx.p.
% Please follow local copyright laws when handling this file.

