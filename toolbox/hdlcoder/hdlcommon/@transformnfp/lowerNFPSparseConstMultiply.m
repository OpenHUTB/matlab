function lowerNFPSparseConstMultiply( hN, multiplyAddMap )




vComps = hN.Components;
for j = 1:length( vComps )
hC = vComps( j );
className = hC.ClassName;
if strcmpi( className, 'nfpsparseconstmultiply_comp' )


constMatrixSize = hC.getConstMatrixSize;
elementVector = hC.getConstMatrix;
constMatrix = reshape( elementVector, constMatrixSize );


sharingFactor = hC.getSharingFactor;
nfpCustomLatency =  - 1;
if hC.getNFPLatency == 4
nfpCustomLatency = hC.getNFPCustomLatency;
end 


hNewC = transformnfp.elabNFPSparseConstMultiply( hN, hC, constMatrix,  ...
sharingFactor, false, multiplyAddMap, nfpCustomLatency );
hNewC.addComment( hC.getComment );
hN.removeComponent( hC );


hdlDriver = hdlcurrentdriver(  );
if hdlDriver.getParameter( 'resourcereport' ) && targetcodegen.targetCodeGenerationUtils.isNFPMode(  )

nfp_stats_map = hdlDriver.nfp_stats;


if isKey( nfp_stats_map, hN.getCtxName(  ) )
nfp_stats = nfp_stats_map( hN.getCtxName(  ) );
nfp_stats.doitOnNetworkOnly( hNewC.ReferenceNetwork );
end 
end 
hN.flattenNic( hNewC );
end 
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpKG1QPC.p.
% Please follow local copyright laws when handling this file.

