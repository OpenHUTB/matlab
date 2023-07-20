

function filename=saveToFile(cvdataObj)

    warnID='Stateflow:Save:UnexpectedObjectID';
    prev_state=warning('query',warnID);
    warning('off',warnID);
    oc=onCleanup(@()warning(prev_state.state,warnID));

    filename=[tempname,'.cvt'];
    try
        cvsave(filename,cvdataObj);
    catch
        filename='';
    end
end