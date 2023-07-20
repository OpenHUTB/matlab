function total_links=findLinks(this)




    if isempty(this.hDocument)
        this.hDocument=rmiref.ExcelUtil.activateDocument(this.docname);
    end
    objectsCollect=this.hDocument.ActiveSheet.OLEObjects;
    objectCnt=objectsCollect.Count;
    links=[];
    this.skipped={};
    for idx=1:objectCnt
        oleObject=objectsCollect.Item(idx);
        try
            ProgID=oleObject.ProgID;
        catch Mex %#ok<NASGU>




            hDoc=this.hDocument;
            if~hDoc.Application.Visible
                hDoc.Application.Visible=1;
            end
            reply=questdlg({...
            getString(message('Slvnv:rmiref:DocCheckExcel:ActxMustBeEnabled')),...
            getString(message('Slvnv:rmiref:DocCheckExcel:IfSecurityWarning')),...
            getString(message('Slvnv:rmiref:DocCheckExcel:ClickContinue')),...
            ' ',...
            getString(message('Slvnv:rmiref:DocCheckExcel:ToAvoidInTheFuture')),...
            getString(message('Slvnv:rmiref:DocCheckExcel:CloseAndRerun')),...
            ' '},...
            getString(message('Slvnv:rmiref:DocCheckExcel:FailedToProcessLinkObjectsInDoc')),...
            getString(message('Slvnv:rmiref:DocCheckExcel:Continue')),...
            getString(message('Slvnv:rmiref:DocCheckExcel:Cancel')),...
            getString(message('Slvnv:rmiref:DocCheckExcel:Continue')));
            if isempty(reply)
                reply=getString(message('Slvnv:rmiref:DocCheckExcel:Cancel'));
            end
            switch reply
            case getString(message('Slvnv:rmiref:DocCheckExcel:Continue'))
                try
                    ProgID=oleObject.ProgID;
                catch Mex
                    error(message('Slvnv:rmiref:DocCheckExcel:DocCheckRun',Mex.message));
                end
            otherwise
                total_links=-1;
                return;
            end
        end
        if any(strcmp(ProgID,{'mwSimulink.SLRefButton','mwSimulink1.SLRefButton','mwSimulink2.SLRefButtonA'}))

            linkObj=oleObject.Object;


            link=rmiref.SLRefExcel(this.hDocument);
            link.srcObj=oleObject;
            link.docname=this.docname;
            link.itemname=linkObj.Name;


            if link.assignRefData(this.sessionId)
                this.skipped{end+1}='';
            elseif~strcmp(link.cmd,'rmiobjnavigate')
                this.skipped{end+1}=getString(message('Slvnv:rmiref:Check:writeReport:UnsupportedCodeLink'));
            else
                this.skipped{end+1}=getString(message('Slvnv:rmiref:Check:writeReport:UnsupportedMultilink'));
            end

            if isempty(links)
                link.idx=1;
                links=link;
            else
                link.idx=links(end).idx+1;
                links(end+1)=link;%#ok<*AGROW>
            end
        end
    end

    if isempty(links)
        total_links=0;
    else
        total_links=length(links);
    end
    this.links=links;

end
