
function reportWarning(warningId,warningMsg)

    warningState=warning('off','backtrace');

    warningMsg=strrep(warningMsg,'\','\\');
    warning(warningId,warningMsg);
    warning(warningState);
end