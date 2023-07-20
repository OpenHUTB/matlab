function importOptions=loadStoredOptions(destinationReqSetPath,docPath,subDoc)


    if nargin>2&&~isempty(subDoc)

        possibleOptionsFile=slreq.import.impOptFile(destinationReqSetPath,docPath,subDoc);
        if exist(possibleOptionsFile,'file')==0

            possibleOptionsFile=slreq.import.impOptFile(destinationReqSetPath,docPath);
        end

    else

        possibleOptionsFile=slreq.import.impOptFile(destinationReqSetPath,docPath);
    end

    if exist(possibleOptionsFile,'file')==2
        loaded=load(possibleOptionsFile);
        importOptions=loaded.importOptions;
    else
        importOptions=[];
    end
end
