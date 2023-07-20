function showLinkConversionSummary(convertCount,unresolvedCount)





    msgStr={};
    if(convertCount>0)
        msgStr{end+1}=getString(message('Slvnv:slreq:UpdatedDirectLinks',convertCount));
    end

    if(unresolvedCount>0)
        msgStr{end+1}=getString(message('Slvnv:slreq:UnableToUpdateDirectLinks',unresolvedCount));
    end

    if isempty(msgStr)
        msgStr=getString(message('Slvnv:slreq:UpdatedDirectLinksNone'));
    end

    msgTitle=getString(message('Slvnv:slreq:UpdatingLinks'));
    msgbox(msgStr,msgTitle);

end
