function total_links=findLinks(this)




    if isempty(this.hDocument)
        this.hDocument=rmiref.WordUtil.activateDocument(this.docname);
    end


    shapeCollect=this.hDocument.InlineShapes;
    shapeCnt=shapeCollect.Count;
    links=[];
    this.skipped={};
    for idx=1:shapeCnt

        shapeObj=shapeCollect.Item(idx);
        if strcmp(shapeObj.Type,'wdInlineShapeOLEControlObject')
            oleFormat=shapeObj.OLEFormat;
            ProgID='';
            if~isempty(oleFormat)
                ProgID=oleFormat.ProgID;
            end

            if any(strcmp(ProgID,{'mwSimulink.SLRefButton','mwSimulink1.SLRefButton','mwSimulink2.SLRefButtonA'}))
                try
                    linkObj=oleFormat.Object;
                catch Mex %#ok<NASGU>




                    hDoc=this.hDocument;
                    if~hDoc.Application.Visible
                        hDoc.Application.Visible=1;
                    end
                    reply=questdlg({...
                    getString(message('Slvnv:rmiref:DocCheckWord:ActxMustBeEnabled')),...
                    getString(message('Slvnv:rmiref:DocCheckWord:IfSecurityWarning')),...
                    getString(message('Slvnv:rmiref:DocCheckWord:ClickContinue')),...
                    ' ',...
                    getString(message('Slvnv:rmiref:DocCheckWord:ToAvoidInFuture')),...
                    getString(message('Slvnv:rmiref:DocCheckWord:CloseAndRerun')),...
                    ' '},...
                    getString(message('Slvnv:rmiref:DocCheckWord:FailedToProcessLinkObjsInDoc')),...
                    getString(message('Slvnv:rmiref:DocCheckWord:Continue')),...
                    getString(message('Slvnv:rmiref:DocCheckWord:Cancel')),...
                    getString(message('Slvnv:rmiref:DocCheckWord:Continue')));
                    if isempty(reply)
                        reply=getString(message('Slvnv:rmiref:DocCheckWord:Cancel'));
                    end
                    switch reply
                    case getString(message('Slvnv:rmiref:DocCheckWord:Continue'))
                        try
                            linkObj=oleFormat.Object;
                        catch Mex
                            error(message('Slvnv:rmiref:DocCheckWord:DocCheckRun',Mex.message));
                        end
                    otherwise
                        total_links=-1;
                        return;
                    end
                end


                link=rmiref.SLRefWord(this.hDocument);
                link.srcShape=shapeObj;
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
    end



    hyperlinks=this.hDocument.Hyperlinks;
    for i=1:hyperlinks.Count
        oneLink=hyperlinks.Item(i);
        address=oneLink.Address;


        matched=regexp(address,'http://(?:localhost|127\.0\.0\.1):\d+/matlab/feval/(rmiobjnavigate\?arguments=\[[^\]]+\])','tokens');
        if~isempty(matched)
            link=rmiref.SLRefWord(this.hDocument);
            link.hLink=oneLink;
            link.docname=this.docname;
            link.itemname=sprintf('rmilink%d',i);


            if link.assignRefData(this.sessionId,matched{1}{1})
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
