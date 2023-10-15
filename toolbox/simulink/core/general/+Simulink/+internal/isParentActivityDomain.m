function retVal = isParentActivityDomain( cbinfo )

arguments
    cbinfo
end

ownerGraphHandle = SLStudio.Utils.getDiagramHandle( cbinfo );
ownerGraphDomain = get_param( ownerGraphHandle, 'SimulinkSubDomain' );
retVal = strcmp( ownerGraphDomain, "ActivityDiagram" );

end

