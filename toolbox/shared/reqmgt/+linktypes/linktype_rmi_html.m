function linktype=linktype_rmi_html

    linktype=ReqMgr.LinkType;
    linktype.Registration=mfilename;
    linktype.Label=getString(message('Slvnv:reqmgt:linktype_rmi_simulink:HTMLFile'));


    linktype.IsFile=1;
    linktype.Extensions={'.htm','.html','.asp','.stm'};


    linktype.LocDelimiters='@';
    linktype.Version='';


    linktype.NavigateFcn=@NavigateFcn;
    linktype.ContentsFcn=@ContentsFcn;
    linktype.CreateURLFcn=@CreateURLFcn;
    linktype.UrlLabelFcn=@UrlLabelFcn;

end


function NavigateFcn(filename,locationStr)
    url=filename;
    if~isempty(locationStr)
        switch(locationStr(1))
        case '@'
            locationStr=locationStr(2:end);
        otherwise

        end
        url=[url,'#',locationStr];
    end
    web(url);
end


function[labels,depths,locations]=ContentsFcn(filePath)
    fid=fopen(filePath,'r');
    contents=char(fread(fid)');
    fclose(fid);

    anchors=regexpi(contents,'<a\s[^>]*?name\s*?=\s*?"?([^>"]+)','tokens');
    namedIds=regexpi(contents,'<[^>]*?id\s*?=\s*?"?([^>"&]+)','tokens');
    anchors=cat(1,anchors{:});
    namedIds=cat(1,namedIds{:});
    labels=[anchors;namedIds];
    locations=strcat('@',labels);
    depths=[];
end


function url=CreateURLFcn(doc,refSrc,locationStr)
    docPath=rmi.locateFile(doc,refSrc);
    if isempty(docPath)
        url='';
    else
        url=rmiut.filepathToUrl(docPath);
        if contains(url,'file://')&&~isempty(locationStr)
            url=[url,'#',locationStr(2:end)];
        end
    end
end


function label=UrlLabelFcn(doc,docLabel,location)
    if~isempty(docLabel)
        doc=docLabel;
    else
        doc=RptgenRMI.shortPath(doc);
    end
    if length(location)>1
        if location(1)=='@'||location(1)=='#'
            location(1)=[];
        end
        label=getString(message('Slvnv:RptgenRMI:ReqTable:execute:DocumentAtPosition',doc,location));
    else
        label=doc;
    end
end
