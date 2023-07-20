


function startSpinner(spinnerText)
    payloadStruct=struct('VirtualChannel','Update/GlobalSpinner',...
    'Payload',struct('text',spinnerText));
    message.publish('/stm/messaging',payloadStruct);

    sltest.internal.Events.getInstance.notifyGlobalSpinnerLabelUpdated(spinnerText);
end
