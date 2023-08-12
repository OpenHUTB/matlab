function simInput = setupSimInputForRunall( simInput )




if ~bdIsLoaded( simInput.ModelName ) ||  ...
~SlCov.CoverageAPI.isSimInputCoverageOn( simInput ) ||  ...
~SlCov.CoverageAPI.checkCvLicense
return ;
end 

simInput = simInput.addHiddenModelParameter( 'CovSaveSingleToWorkspaceVar', 'on' );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpJP8dA3.p.
% Please follow local copyright laws when handling this file.

