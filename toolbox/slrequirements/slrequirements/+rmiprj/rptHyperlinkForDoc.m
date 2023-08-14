function dLink=rptHyperlinkForDoc(doc,resolved,sys,ref,docgen)




    if nargin<5
        docgen=get(rptgen.appdata_rg,'CurrentDocument');
    end

    linkType=rmi.linktype_mgr('resolveByRegName',sys);
    if isempty(resolved)
        if isempty(linkType)
            linkType=rmi.linktype_mgr('resolveByFileExt',doc);
        end
        if~isempty(linkType)&&~isempty(linkType.CreateUrlFcn)
            url=makeUrlForDocument(linkType,doc,ref);
            dLink=docgen.makeLink(url,doc,'ulink');
        else
            docPath=strrep(doc,'\',filesep);

            if exist(docPath,'file')==2
                dLink=docgen.makeLink(docPath,doc,'ulink');
            else
                dLink=docPath;
            end
        end
    else
        if isempty(linkType)
            linkType=rmi.linktype_mgr('resolveByFileExt',resolved);
        end
        if~isempty(linkType)&&~isempty(linkType.CreateUrlFcn)
            if linkType.isFile&&~strncmp(resolved,'http://',length('http://'))&&rmipref('ReportUseRelativePath')
                relPath=rmiut.relative_path(resolved,pwd);
                url=makeUrlForDocument(linkType,relPath,ref);
            elseif rmisl.isHarnessIdString(doc)

                url=makeUrlForDocument(linkType,resolved,doc);



                [parentName,uuidString]=strtok(doc,':');
                harnessInfo=Simulink.harness.find(parentName,'UUID',uuidString(2:end));
                if~isempty(harnessInfo)
                    doc=harnessInfo(1).name;
                end
            else
                url=makeUrlForDocument(linkType,resolved,ref);
            end
            dLink=docgen.makeLink(url,doc,'ulink');
        else

            url=rmiut.filepathToUrl(resolved);
            dLink=docgen.makeLink(url,doc,'ulink');
        end
    end
end

function url=makeUrlForDocument(linkType,doc,ref)

    req=rmi.createEmptyReqs(1);
    req.reqsys=linkType.registration;
    if rmisl.isHarnessIdString(ref)

        req.doc=ref;
        ref='';
    else
        req.doc=doc;
    end
    url=rmi.reqToUrl(req,ref,rmipref('ReportNavUseMatlab'),linkType);
end
