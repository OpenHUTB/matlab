function updateTestCaseSpinnerLabel( testCaseId, spinnerText, nameValuePairs )
arguments
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
