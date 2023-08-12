function publishEventResponse( requestId, status, msg )







R36
requestId{ mustBeTextScalar, mustBeNonzeroLengthText }
status( 1, 1 )logical
msg{ mustBeTextScalar }
end 

requestId = strip( requestId );
if strlength( requestId ) == 0
error( "requestId must contain at least one non-whitespace character" );
end 

payload = coderapp.internal.util.EventResult(  );
payload.RequestId = requestId;
payload.Passed = status;
payload.Message = msg;

message.publish( "/mlc/global/mfzEventResponse/" + requestId, payload );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpPup4DU.p.
% Please follow local copyright laws when handling this file.

