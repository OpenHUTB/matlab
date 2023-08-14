function linktype=linktype_rmi_url







    linktype=ReqMgr.LinkType;
    linktype.Registration=mfilename;


    linktype.Label=getString(message('Slvnv:reqmgt:linktype_rmi_simulink:WebBrowserURL'));


    linktype.IsFile=0;
    linktype.Extensions={};


    linktype.LocDelimiters='@';
    linktype.Version='';



    linktype.NavigateFcn=@NavigateFcn;
    linktype.CreateURLFcn=@CreateURLFcn;
    linktype.UrlLabelFcn=@UrlLabelFcn;
    linktype.ResolveDocFcn=@ResolveDocFcn;

end

function NavigateFcn(target,locationStr)

    if~isempty(locationStr)&&isempty(strfind(target,'#'))
        switch(locationStr(1))
        case '@'
            target=[target,'#',locationStr(2:end)];
        otherwise

        end
    end
    web(target,'-browser','-display');
end

function url=CreateURLFcn(doc,~,locationStr)
    url=doc;
    if~isempty(locationStr)
        if locationStr(1)=='@'
            url=[url,'#',locationStr(2:end)];
        elseif locationStr(1)=='#'
            url=[url,locationStr];
        else
            url=[url,'#',locationStr];
        end
    end
end

function label=UrlLabelFcn(doc,docLabel,locationStr)
    if isempty(docLabel)
        docStr=RptgenRMI.shortUrl(doc);
    else
        docStr=docLabel;
    end
    if length(locationStr)>1&&locationStr(1)=='@'
        label=getString(message('Slvnv:RptgenRMI:ReqTable:execute:DocumentAtPosition',...
        docStr,locationStr(2:end)));
    else
        label=docStr;
    end
end

function[docPath,isRel]=ResolveDocFcn(doc,~)
    [is_url,url]=rmiut.is_url(doc);
    if is_url
        docPath=url;
    else
        docPath=doc;
    end
    isRel=false;
end


