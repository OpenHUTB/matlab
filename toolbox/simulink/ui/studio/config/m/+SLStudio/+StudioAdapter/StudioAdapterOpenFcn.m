function adapterEditor = StudioAdapterOpenFcn( blockHandle, urlLinkStr, openTypeStr )
arguments
    blockHandle( 1, 1 ){ mustBeNumeric, SLStudio.StudioAdapter.mustBeValidSimulinkHandle, SLStudio.StudioAdapter.mustBeRegisteredBlockType }
    urlLinkStr( 1, : ){ mustBeURL }
    openTypeStr( 1, : ){ SLStudio.StudioAdapter.mustBeOpenTypeEnum } = 'REUSE_TAB'
end

adapterDiagram = SA_M3I.StudioAdapterDomain.getCreateStudioAdapterDiagramForBlockHandle( blockHandle );
adapterEditor = SLStudio.StudioAdapter.openStudioAdapterEditor( adapterDiagram, openTypeStr );
SLStudio.StudioAdapter.attachWebContentToEditor( adapterEditor, urlLinkStr );
end

function mustBeURL( urlLinkStr )
SLStudio.StudioAdapter.mustBeString( urlLinkStr, 'URL link is not a string' );
end
