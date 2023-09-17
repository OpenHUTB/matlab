function report = getErrorReportWithCallStack( ME, options )

R36
ME( 1, 1 )MException
options.ProjectPath( 1, : )char = ''
options.SnapshotPath( 1, : )char = ''
options.RunID( 1, : )char = ''
options.WorkerError = [  ]
end 


report = ME.getReport( 'basic' );
causedBy = message( 'MATLAB:MException:CausedBy' ).getString(  );
report = string( [ report, newline, causedBy ] );
for k = 1:length( ME.cause )
cause = ME.cause{ k };
if ~isempty( options.WorkerError )
causeReport = options.WorkerError.report;
elseif ~isempty( options.ProjectPath )
causeReport = experiments.internal.getErrorReport( cause, 'ProjectPath', options.ProjectPath );
else 
causeReport = experiments.internal.getErrorReport( cause,  ...
'SnapshotPath', options.SnapshotPath,  ...
'RunID', options.RunID );
end 
causeReport = strrep( causeReport, causedBy, '' );
causeReport = "    " + join( splitlines( causeReport ), newline + "    " ) + newline;
report = report + causeReport;
end 
end 



