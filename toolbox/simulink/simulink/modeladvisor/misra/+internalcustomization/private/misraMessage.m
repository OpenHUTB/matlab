






function message=misraMessage(checkID,messageID)
    if nargin==1
        messageID=checkID;
        message=DAStudio.message(['RTW:misra:Common_',messageID]);
    else
        message=DAStudio.message(['RTW:misra:',checkID,'_',messageID]);
    end
end

