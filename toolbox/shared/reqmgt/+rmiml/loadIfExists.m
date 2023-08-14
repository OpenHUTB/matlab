function success=loadIfExists(mFileName)




    if rmiml.hasData(mFileName)
        success=true;
    else
        success=slreq.utils.loadLinkSet(mFileName);
    end
end

