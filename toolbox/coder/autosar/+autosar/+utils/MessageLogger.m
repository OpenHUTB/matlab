classdef MessageLogger < handle





properties ( Access = private )
Messages;
end 

methods 
function logError( this, id, varargin )

this.Messages = [ this.Messages; ...
this.createMessage( 'Error', id, varargin{ : } ) ];
end 

function logWarning( this, id, varargin )

this.Messages = [ this.Messages; ...
this.createMessage( 'Warning', id, varargin{ : } ) ];
end 

function flush( this, parentMsgId, namedargs )


R36
this
parentMsgId
namedargs.ParentMsgArgs = {  };
namedargs.onlyErrors = false;
end 

parentException = MSLException( [  ], message( parentMsgId, namedargs.ParentMsgArgs{ : } ) );

for ii = 1:length( this.Messages )
msg = this.Messages( ii );
switch ( msg.Type )
case 'Error'
cause = MSLException( [  ], msg.MessageObject );
parentException = parentException.addCause( cause );
case 'Warning'
if ~namedargs.onlyErrors

WarnTraceCleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>
MSLDiagnostic( msg.MessageObject ).reportAsWarning;
end 
otherwise 
assert( false, 'Unexpected message kind %s.', msg.Type );
end 
end 

if ~isempty( parentException.cause )
parentException.throw(  );
end 
end 
end 

methods ( Static, Access = private )
function msg = createMessage( type, id, varargin )
msg = struct(  ...
'Type', type,  ...
'MessageObject', message( id, varargin{ : } ) );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp3NluaD.p.
% Please follow local copyright laws when handling this file.

