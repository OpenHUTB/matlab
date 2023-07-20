function status=synchronizeStatus(index,artifactUri,numChanges,exMessage,nonUniqueCustomIds)

    status=struct('message','','id','');

    if numChanges==-1

        status.id='Slvnv:slreq_import:SynchroErrorDetails';
        status.message=getString(message(status.id,exMessage));
    elseif numChanges>0
        status.id='Slvnv:slreq_import:SynchroSuggestionChanges';

        status.message=getString(message(status.id,index));



    else
        status.id='Slvnv:slreq_import:SynchroSuggestionNoChange';
        status.message=getString(message(status.id));
    end


    if~isempty(nonUniqueCustomIds)
        nonUniqueIdsStr=strjoin(nonUniqueCustomIds,', ');




        MAX_LENGTH=77;
        if length(nonUniqueIdsStr)>=MAX_LENGTH
            nonUniqueIdsStr=nonUniqueIdsStr(1:MAX_LENGTH);
            nonUniqueIdsStr=[nonUniqueIdsStr,'...'];
        end

        status.id='Slvnv:slreq_import:SynchroCustomIdsNotUnique';
        status.message=getString(message(status.id,nonUniqueIdsStr,artifactUri));
    end
end