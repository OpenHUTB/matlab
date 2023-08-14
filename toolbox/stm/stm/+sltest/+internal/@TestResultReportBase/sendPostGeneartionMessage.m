function sendPostGeneartionMessage(~,fromCMD,requirementDataRejected)





    if(fromCMD&&requirementDataRejected)
        warning OFF BACKTRACE;
        warning('stm:general:NoSLVnVLicenseForRequirementInReport',...
        getString(message('stm:general:NoSLVnVLicenseForRequirementInReport')));
        warning ON BACKTRACE;
    end

    virtualChannel=sprintf('Report/Generation/POSTMSG');
    postMSG=struct('requrementDataRejected',requirementDataRejected,'fromCMD',fromCMD);
    payloadStruct=struct('VirtualChannel',virtualChannel,'Payload',postMSG);
    message.publish('/stm/messaging',payloadStruct);
end