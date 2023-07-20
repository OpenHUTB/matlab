



function verifyInputBlockSID(obj,msgData)

    blockTabSummary="";
    src=slci.view.internal.getSource(obj.getStudio);


    inputBlockSidFromUi=regexp(msgData.BlockSId,',','split');
    for i=1:numel(inputBlockSidFromUi)
        splitBlockSid=regexp(inputBlockSidFromUi(i),':','split');
        inputModelNameFromSid=splitBlockSid{1,1}{1};

        if~isequal(src.modelName,inputModelNameFromSid)
            blockTabSummary=DAStudio.message('Slci:slcireview:JustificationModelInvalidModelName');
            break;
        end

        if~Simulink.ID.isValid(inputBlockSidFromUi(i))
            blockTabSummary=DAStudio.message('Slci:slcireview:JustificationModelInvalidBlockSid');
            break;
        end
    end


    msg.Summary=blockTabSummary;
    msg.msgID='getVerifyInputBlockSID';
    msg.type='getVerifyInputBlockSID';
    message.publish(obj.getChannel,msg);
end