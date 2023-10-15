function retVal = isParentArchitectureDomain( cbinfo, subDomain )

arguments
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
