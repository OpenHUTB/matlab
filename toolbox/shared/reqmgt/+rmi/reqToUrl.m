function[url,label,fPath]=reqToUrl(req,ref,useMatlabConnector,linkType)








































    label=req.description;
    if length(label)>100
        label=[label(1:90),'...'];
    elseif isempty(label)
        label=getString(message('Slvnv:RptgenRMI:ReqTable:execute:DocumentAtPosition',req.doc,req.id));
    end




    fPath='';


    if isempty(req.doc)
        warnNoBacktrace(message('Slvnv:rmiut:matlabConnectorOn:UnableToGenerate',label));
        url='';
        return;
    end


    if nargin<4||isempty(linkType)
        if strcmp(req.reqsys,'other')
            linkType=rmi.linktype_mgr('resolveByFileExt',req.doc);
        else
            linkType=rmi.linktype_mgr('resolveByRegName',req.reqsys);
        end
        if isempty(linkType)





            [url,fPath]=fileUrl(req,ref);
            return;
        end
    end

    if~isempty(ref)&&~ischar(ref)
        ref=get_param(ref,'Name');
    end

    if isURLType(linkType.Registration)

        url=noMCURL(req,linkType,ref);
    else


        if nargin<3||isempty(useMatlabConnector)
            useMatlabConnector=rmipref('ReportNavUseMatlab')||...
            (isSlLinktype(req.reqsys)&&rmipref('ReportLinkToObjects'));


        end
        if useMatlabConnector

            navCmd=sprintf('rmi.navigate(''%s'',''%s'',''%s'',''%s'');',...
            req.reqsys,req.doc,req.id,ref);
            url=rmiut.cmdToUrl(navCmd);

        else

            url=noMCURL(req,linkType,ref);
        end
    end
end

function url=noMCURL(req,linkType,ref)




    if~rmipref('ReportLinkToObjects')&&isSlLinktype(req.reqsys)



        if strcmp(req.reqsys,'linktype_rmi_slreq')
            dataRef=slreq.internal.getImportedReference(req);
            if~isempty(dataRef)
                url=getSourceUrl(dataRef);
            else
                url='';
            end
        else

            req.doc=rmi.ensureFilenameExtension(req.doc,req.reqsys);
            url=fileUrl(req,ref);
        end

    elseif~isempty(linkType.CreateURLFcn)


        url=feval(linkType.CreateURLFcn,req.doc,ref,req.id);

    elseif linkType.IsFile

        url=fileUrl(req,ref);
    else

        warnNoBacktrace(message('Slvnv:rmiut:matlabConnectorOn:UnableToGenerate',req.doc));
        url=req.doc;
    end
end

function yesno=isURLType(reqsys)
    yesno=any(strcmp(reqsys,{...
    'linktype_rmi_html',...
    'linktype_rmi_oslc',...
    'linktype_rmi_url'}));


end


function yesno=isSlLinktype(reqsys)
    yesno=any(strcmp(reqsys,{...
    'linktype_rmi_data',...
    'linktype_rmi_matlab',...
    'linktype_rmi_simulink',...
    'linktype_rmi_slreq',...
    'linktype_rmi_testmgr'}));
end

function[url,fPath]=fileUrl(req,ref)
    fPath=rmi.locateFile(req.doc,ref);
    if isempty(fPath)
        url='';
        return;
    end
    url=rmiut.filepathToUrl(fPath);
    if length(req.id)>1&&req.id(1)=='@'
        url=[url,'#',req.id(2:end)];
    end
end

function warnNoBacktrace(myMessage)
    s=warning('off','backtrace');
    warning(myMessage);
    warning(s.state,'backtrace');
end

function url=getSourceUrl(dataRef)
    url='';
    docApi=rmi.linktype_mgr('resolveByRegName',dataRef.domain);
    if~isempty(docApi.CreateURLFcn)
        url=docApi.CreateURLFcn(dataRef.artifactUri,'',dataRef.artifactId);
    end
end


