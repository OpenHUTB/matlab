function sigRows=sanitizeBindModeRows(sigRows)






    checkedBusRowId='';
    indxOfConnectedRows=[];
    for indx=1:length(sigRows)

        if strcmp(sigRows{indx}.bindableTypeChar,'BUSOBJECT')&&sigRows{indx}.isConnected
            checkedBusRowId=sigRows{indx}.bindableMetaData.id;
        end

        if strcmp(sigRows{indx}.bindableTypeChar,'BUSLEAFSIGNAL')&&...
            strcmp(checkedBusRowId,sigRows{indx}.bindableMetaData.parentId)
            sigRows{indx}.isConnected=true;
        end


        if sigRows{indx}.isConnected
            indxOfConnectedRows(end+1)=indx;
        end
    end


    temp=sigRows(indxOfConnectedRows);
    sigRows(indxOfConnectedRows)=[];
    sigRows=[temp,sigRows];
end