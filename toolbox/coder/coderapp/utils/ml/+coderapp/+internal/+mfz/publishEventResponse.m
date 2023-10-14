function publishEventResponse( requestId, status, msg )

arguments
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

