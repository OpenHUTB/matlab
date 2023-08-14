function warnNonUniqueCustomIds(sourceDoc,nonUniqueCustomIds)

    if isempty(nonUniqueCustomIds)

        return;
    end




    nonUniqueIdsStr=strjoin(nonUniqueCustomIds,', ');




    MAX_LENGTH=77;
    if length(nonUniqueIdsStr)>=MAX_LENGTH
        nonUniqueIdsStr=nonUniqueIdsStr(1:MAX_LENGTH);
        nonUniqueIdsStr=[nonUniqueIdsStr,'...'];
    end


    errorId='Slvnv:slreq_import:SynchroCustomIdsNotUnique';
    errorMsg=getString(message(errorId,nonUniqueIdsStr,sourceDoc));


    mgr=slreq.app.MainManager.getInstance;
    reqRoot=mgr.reqRoot;
    if~isempty(reqRoot)
        reqRoot.showSuggestion(errorId,errorMsg);
    else
        errordlg(errorMsg,getString(message('Slvnv:slreq:Error')));
    end
end

