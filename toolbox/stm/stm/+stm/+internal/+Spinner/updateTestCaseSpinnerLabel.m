












function updateTestCaseSpinnerLabel( testCaseId, spinnerText, nameValuePairs )
R36
testCaseId( 1, 1 )double
spinnerText( 1, 1 )string
nameValuePairs.Type( 1, 1 )string = ''
nameValuePairs.ShowSpinner( 1, 1 )logical = false
end 

payloadStruct = struct( 'VirtualChannel', 'Update/SpinnerLabel', 'Payload',  ...
struct( 'testCaseId', testCaseId, 'spinnerText', spinnerText, 'type', nameValuePairs.Type, 'showSpinner', nameValuePairs.ShowSpinner ) );
message.publish( '/stm/messaging', payloadStruct );

sltest.internal.Events.getInstance.notifyTestSpinnerLabelUpdated( testCaseId, spinnerText );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp1P31Nb.p.
% Please follow local copyright laws when handling this file.

