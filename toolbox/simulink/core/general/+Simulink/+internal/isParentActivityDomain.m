function retVal = isParentActivityDomain( cbinfo )



R36
cbinfo
end 

ownerGraphHandle = SLStudio.Utils.getDiagramHandle( cbinfo );
ownerGraphDomain = get_param( ownerGraphHandle, 'SimulinkSubDomain' );
retVal = strcmp( ownerGraphDomain, "ActivityDiagram" );

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpSrWjOB.p.
% Please follow local copyright laws when handling this file.

