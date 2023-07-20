function[errorCount,warningCount,messageCount,errorStr,warningStr,messageStr]=statusCount(~,checks)


    errorCount=0;
    warningCount=0;
    messageCount=0;

    for i=1:length(checks)
        if strcmpi(checks(i).level,'Error')
            errorCount=errorCount+1;
        elseif strcmpi(checks(i).level,'Warning')
            warningCount=warningCount+1;
        elseif strcmpi(checks(i).level,'Message')
            messageCount=messageCount+1;
        end
    end

    if(nargout>3)
        [errorStr,warningStr,messageStr]=statusMsg(errorCount,warningCount,messageCount);
    end
end


function[errorStr,warningStr,messageStr]=statusMsg(errorCount,warningCount,messageCount)

    if errorCount==1
        errorStr='error';
    else
        errorStr='errors';
    end

    if warningCount==1
        warningStr='warning';
    else
        warningStr='warnings';
    end

    if messageCount==1
        messageStr='message';
    else
        messageStr='messages';
    end
end
