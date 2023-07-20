













function resetTestCaseSpinner(testCaseId)

    payloadStruct=struct('VirtualChannel','Reset/SpinnerLabel','Payload',...
    struct('testCaseId',testCaseId));
    message.publish('/stm/messaging',payloadStruct);

end

