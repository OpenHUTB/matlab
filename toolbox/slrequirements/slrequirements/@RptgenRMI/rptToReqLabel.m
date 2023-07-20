function display_string=rptToReqLabel(linkType,req,showDoc,showId,allDocsIndex)



    if nargin==5
        docLabel=RptgenRMI.getDocId(req.doc,allDocsIndex,req.doc);
    else

        if isempty(linkType)
            docLabel=req.doc;
        elseif strcmp(linkType.Registration,'linktype_rmi_simulink')
            [~,docLabel]=fileparts(req.doc);
        elseif linkType.isFile
            [dDir,dName,dExt]=fileparts(req.doc);
            if length(dDir)>2&&(dDir(1)=='/'||dDir(2)==':')
                docLabel=[dName,dExt];
            else
                docLabel=req.doc;
            end
        else
            docLabel=req.doc;
        end
    end

    if~isempty(linkType)&&~isempty(linkType.UrlLabelFcn)
        if showDoc&&showId
            display_string=feval(linkType.UrlLabelFcn,req.doc,docLabel,req.id);
        elseif showDoc||isempty(req.id)
            display_string=feval(linkType.UrlLabelFcn,req.doc,docLabel,'');
        else
            display_string=feval(linkType.UrlLabelFcn,req.id,docLabel,'');
        end
    else
        locationId=req.id;
        if isempty(locationId)||~showId
            display_string=docLabel;
        else
            if~isempty(linkType)
                locTypes=linkType.LocDelimiters;
                if~isempty(locTypes)&&any(locTypes==locationId(1))
                    locationId=locationId(2:end);
                end
            end
            if showDoc
                display_string=getString(message('Slvnv:RptgenRMI:ReqTable:execute:DocumentAtPosition',docLabel,locationId));
            else
                display_string=locationId;
            end
        end
    end
end
