function simInput = setupSimInputForCoverage( simInput, workingDir, useUniqueFileName, isSerial )





if ( nargin < 4 )
isSerial = false;
end 
if ( nargin < 3 )
useUniqueFileName = true;
end 
if ~SlCov.CoverageAPI.isSimInputCoverageOn( simInput ) ||  ...
~SlCov.CoverageAPI.isCvInstalled
return ;
end 

[ outputDir, dataFileName ] = SlCov.CoverageAPI.getCovOutputFullDir( simInput, workingDir );

[ ~, dataFileName ] = fileparts( dataFileName );
runId = simInput.RunId;
dataFileName = append( dataFileName, '_', num2str( runId ) );
if useUniqueFileName
dataFileName = append( cvi.TopModelCov.getUniqueFileName( outputDir, dataFileName ), '.cvt' );
else 
simInput = simInput.addHiddenModelParameter( 'CovFileNameIncrementing', 'off' );
end 

simInput = simInput.addHiddenModelParameter( 'CovOutputDir', outputDir );
simInput = simInput.addHiddenModelParameter( 'CovDataFileName', dataFileName );

if ~isSerial
simInput = simInput.addHiddenModelParameter( 'CovSaveOutputData', 'on' );
simInput = simInput.addHiddenModelParameter( 'CovEnableCumulative', 'off' );
end 

simInput = simInput.addHiddenModelParameter( 'CovShowResultsExplorer', 'off' );
simInput = simInput.addHiddenModelParameter( 'CovHighlightResults', 'off' );
simInput = simInput.addHiddenModelParameter( 'CovHtmlReporting', 'off' );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpZJsYhM.p.
% Please follow local copyright laws when handling this file.

