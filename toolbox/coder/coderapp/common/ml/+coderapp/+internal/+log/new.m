

function logger = new( newOpts, loggerOpts )
R36
newOpts.Enabled( 1, 1 ){ mustBeNumericOrLogical( newOpts.Enabled ) } = coderapp.internal.globalconfig( 'EnableLogging' )
newOpts.Sink{ mustBeA( newOpts.Sink, [ "coderapp.internal.log.LogSink", "char", "string" ] ) }
newOpts.BaseId{ mustBeValidVariableName( newOpts.BaseId ) } = 'logger'
newOpts.Id{ mustBeValidVariableName( newOpts.Id ) }
loggerOpts.Level( 1, 1 )uint8
loggerOpts.Locked( 1, 1 ){ mustBeNumericOrLogical( loggerOpts.Locked ) }
end 

if ~newOpts.Enabled
logger = coderapp.internal.log.DummyLogger(  );
return 
end 

if isfield( newOpts, 'Sink' )
if ~isa( newOpts.Sink, 'coderapp.internal.log.LogSink' )
switch newOpts.Sink
case 'print'
loggerOpts.Sink = coderapp.dev.log.PrintLogSink(  );
otherwise 
[ ~, ~, ext ] = fileparts( newOpts.Sink );
if isempty( ext )
loggerOpts.Sink = coderapp.dev.log.MultiFileLogSink( Folder = loggerOpts.Sink );
else 
loggerOpts.Sink = coderapp.dev.log.TextFileLogSink( File = loggerOpts.Sink );
end 
end 
else 
loggerOpts.Sink = newOpts.Sink;
end 
end 

if isfield( newOpts, 'Id' )
id = newOpts.Id;
else 
id = coderapp.internal.util.readableId( newOpts.BaseId, AlwaysAppendNumber = false );
end 

args = namedargs2cell( loggerOpts );
logger = coderapp.internal.log.Logger.createRoot( 'Id', id, args{ : } );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp4LqwSR.p.
% Please follow local copyright laws when handling this file.

