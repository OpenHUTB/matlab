function updateSampleTimesForBBSubModels( this, Models )




numModels = numel( Models );

if numModels > 0

for ii = 1:numModels
mdlName = Models( ii ).modelName;
dirPath = [ this.hdlGetBaseCodegendir, filesep, mdlName ];
matFile = [ dirPath, filesep, 'hdlcodegenstatus.mat' ];
clear( 'CodeGenStatus' );
load( matFile, 'CodeGenStatus' );

modelST = CodeGenStatus.clockReportDatt.modelBaseRate;
if any( isnan( modelST ) )
error( message( 'hdlcoder:engine:unspecifiedsampletime', mdlName ) );
end 


modelST = modelST( ~isnan( modelST ) & ~isinf( modelST ) & modelST >= 0 );
this.PirInstance.setModelSampleTimes( modelST );
this.PirInstance.addDutSampleTime( modelST );
this.PirInstance.addProtectedModelSampleTime( modelST );
end 

end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmphLHdWn.p.
% Please follow local copyright laws when handling this file.

