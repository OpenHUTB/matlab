function setupRefMdlForInstanceCov( refMdlH, mdlBlkH, topMdlH )




try 
if SlCov.CoverageAPI.isModelRefInstanceCovEnabled( topMdlH )
coveng = cvi.TopModelCov.getInstance( topMdlH );
if ~isempty( coveng.covModelRefData )
refMdlName = getfullname( refMdlH );

if Simulink.internal.isModelReferenceMultiInstanceNormalModeCopy( refMdlName )
coveng.addMdlRef( refMdlName );
modelcovId = get_param( refMdlName, 'CoverageId' );
cv( 'set', modelcovId, '.isCopyRefMdl', true );
end 

coveng.covModelRefData.mdlBlkToCopyMdlMap( Simulink.ID.getSID( mdlBlkH ) ) = refMdlName;
end 
end 
catch Mex
rethrow( Mex );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpcCBY5G.p.
% Please follow local copyright laws when handling this file.

