function tf=hasValidDest(linkInfo)




    if isa(linkInfo,'slreq.das.Link')
        dataLink=linkInfo.dataModelObj;
    elseif isa(linkInfo,'slreq.data.Link')
        dataLink=linkInfo;
    else
        error('Illegal argument: only das or data link object supported');
    end


    destObj=dataLink.dest;
    if isempty(destObj)
        tf=false;
        return;
    end

    switch destObj.domain
    case{'linktype_rmi_simulink','linktype_rmi_matlab','linktype_rmi_data','linktype_rmi_testmgr'}



        warningState=warning('off');
        try
            artifactFullpath=rmi.locateFile(destObj.artifactUri,dataLink.source.artifactUri);
            warning(warningState);
        catch ex

            warning(warningState);

            rethrow(ex);
        end

        if isempty(artifactFullpath)

            artifactFullpath=which(destObj.artifactUri);
            if isempty(artifactFullpath)

                artifactFullpath=destObj.artifactUri;
            end
        end

        isLoaded=slreq.utils.isArtifactLoaded(destObj.domain,artifactFullpath);
        if isLoaded||strcmpi(destObj.domain,'linktype_rmi_data')




            try



                warningState1=warning('off');
                tf=slreq.utils.isValidItem(destObj.domain,artifactFullpath,destObj.artifactId);
                warning(warningState1);
            catch ex
                warning(warningState1);

                rethrow(ex)
            end
        else
            tf=false;
        end
    otherwise
        tf=true;
    end
end