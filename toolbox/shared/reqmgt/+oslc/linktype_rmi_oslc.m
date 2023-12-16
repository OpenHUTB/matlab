function linktype=linktype_rmi_oslc

    linktype=ReqMgr.LinkType;
    linktype.Registration=mfilename;
    linktype.Label=getString(message('Slvnv:oslc:LinkableDomainLabel'));

    linktype.IsFile=0;
    linktype.Extensions={};

    linktype.LocDelimiters='#';
    linktype.Version='';

    linktype.NavigateFcn=@NavigateFcn;

    linktype.CreateURLFcn=@CreateURLFcn;
    linktype.UrlLabelFcn=@UrlLabelFcn;
    linktype.HtmlViewFcn=@HtmlViewFcn;
    linktype.DocDateFcn=@DocDateFcn;

    linktype.BrowseFcn=@SelectProject;
    linktype.ContentsFcn=@ContentsFcn;
    linktype.ItemIdFcn=@ItemIdFcn;
    linktype.SelectionLinkLabel=getString(message('Slvnv:oslc:LinkToCurrent'));
    linktype.SelectionLinkFcn=@SelectionLinkFcn;
    linktype.BacklinkCheckFcn=@BacklinkCheckFcn;
    linktype.BacklinkInsertFcn=@BacklinkInsertFcn;
    linktype.BacklinkDeleteFcn=@BacklinkDeleteFcn;
    linktype.BacklinksCleanupFcn=@BacklinksCleanupFcn;
end


function NavigateFcn(doc,id)

    target=oslc.getNavURL(doc,id);
    web(target,'-browser','-display');
end


function url=CreateURLFcn(doc,~,id)
    url=oslc.getNavURL(doc,id);
end


function label=UrlLabelFcn(doc,~,id)

    match=regexp(doc,'^\S+ \((.+)\)','tokens');
    if isempty(match)
        docStr=doc;
        if length(docStr)>50
            docStr=[docStr(50:end),'...'];
        end
    else
        docStr=match{1}{1};
    end
    if isempty(id)
        label=docStr;
    else
        match=regexp(id,'^\S+ \((\d+)\)','tokens');
        if isempty(match)
            idStr=id;
            if length(idStr)>50
                idStr=[idStr(50:end),'...'];
            end
        else
            idStr=match{1}{1};
        end
        label=getString(message('Slvnv:oslc:ItemInProject',idStr,docStr));
    end
end


function dateStr=DocDateFcn(docId)
    try
        if inputIsNumericId(docId)
            req=oslc.getReqItem(docId);
            connection=oslc.connection();
            rdf=char(connection.get(req.resource));
            dateStr=oslc.parseValue(rdf,'dcterms:modified');
            dateStr=strrep(strtok(dateStr,'.'),'T',' ');

        elseif any(docId=='(')
            match=regexp(docId,'^\S+ \((.+)\)','tokens');
            if isempty(match)
                dateStr=getString(message('Slvnv:oslc:Unavailable'));
            else
                docStr=match{1}{1};
                dateStr=oslc.Project.getDate(docStr);
                dateStr=strrep(strtok(dateStr,'.'),'T',' ');
            end
        else
            dateStr=getString(message('Slvnv:oslc:FailedToQueryDate',docId));
        end
    catch ex
        dateStr=getString(message('Slvnv:oslc:FailedToQueryDate',ex.message));
    end
end


function tf=inputIsNumericId(in)
    if isnumeric(in)
        tf=(floor(in)==in);
    else
        tf=all(double(in)>=double('0')&double(in)<=double('9'));
    end
end


function html=HtmlViewFcn(doc,id)
    html='';
    if isempty(id)
        return;
    end
    connection=oslc.connection();
    if isempty(connection)
        return;
    end
    resourceURI=strtok(id);
    reqRdf=connection.get(resourceURI);
    htmlText=oslc.parseValue(char(reqRdf),'jazz_rm:primaryText');
    if isempty(htmlText)
        html=['<html><h2>',id,' in ',doc,'</h2>UNDER CONSTRUCTIION</html>'];
    else
        html=htmlText;
    end
end


function reqstruct=SelectionLinkFcn(callerObj,make2way,allowMultiselect)

    if nargin<3
        allowMultiselect=true;
    end

    reqstruct=[];

    [id,label]=oslc.selection();%#ok<ASGLU>  We used to rely on LABEL 

    if isempty(id)

        if reqmgt('rmiFeature','DngModuleSelector')||oslc.promptForSelection()

            oslc.manualSelectionLink(callerObj,make2way,allowMultiselect);
        elseif~allowMultiselect
            ReqMgr.activeDlgUtil('clear');
        end
        reqstruct='';
        return;

    elseif~allowMultiselect&&length(id)>1
        errordlg(...
        getString(message('Slvnv:reqmgt:linktype_rmi_simulink:SelectionLinkTooManyObjects')),...
        getString(message('Slvnv:reqmgt:linktype_rmi_simulink:RequirementsUseCurrent')));
        return;

    end

    currentProjName=oslc.Project.currentProject();

    if isempty(currentProjName)

        errordlg(...
        getString(message('Slvnv:oslc:SearchingForIdWithoutProject')),...
        getString(message('Slvnv:oslc:CurrentProjectNotSetDlg')));
        return;
    else
        try
            if~oslc.confirmContext(currentProjName)
                return;
            end
        catch ex
            contextMsg=getString(message('Slvnv:oslc:BrowserContextDefault'));
            rmiut.warnNoBacktrace([ex.message,newline,contextMsg]);

        end
    end
    reqstruct=rmi.createEmptyReqs(length(id));

    for i=1:length(id)

        [req,projName]=oslc.getReqItem(id(i),'',true);

        if isempty(req)


            if~isempty(projName)
                scopeInfo=projName;
            else
                scopeInfo=oslc.server();
            end
            rmiut.warnNoBacktrace('Slvnv:oslc:FailedToFindIdInProject',...
            num2str(id(i)),scopeInfo);
            beep;
            oslc.selection('','');
            reqstruct=[];
            return;

        elseif isa(req,'oslc.Requirement')

            reqstruct(i)=oslc.makeReq(req);
            if make2way

                [targetURL,mwObjLabel,errMsg]=slreq.connector.getMwItemUrlAndLabel(callerObj);
                if~isempty(targetURL)
                    oslc.addLinkFromResource(req,targetURL,mwObjLabel);
                elseif~isempty(errMsg)
                    rmiut.warnNoBacktrace('Slvnv:slreq_backlinks:FailedToAddBacklinkReason',mwObjLabel,errMsg);
                end
            end

        else


            switch(req)
            case 'TESTING'


                testreq=reqstruct;
                testreq.doc='https://AUTOMATED.TEST/PROJECT_AREA (TEST)';
                testreq.id='https://AUTOMATED.TEST/RESOURCE_URI (0)';
                testreq.description='AUTOMATED TEST';
                testreq.reqsys='linktype_rmi_oslc';
                reqstruct=testreq;
                return;
            case 'CANCEL'

                reqstruct=[];
                return;
            case 'RELAY'


                oslc.manualSelectionLink(callerObj,make2way,allowMultiselect);
                reqstruct=[];
                return;
            otherwise
                error('Invalid string returned by oslc.getReqItem(): "%s"',req);
            end
        end
    end
end

function project=SelectProject()

    dngDlg=oslc.DlgSelectProject();
    DAStudio.Dialog(dngDlg);

    project=' ';

end

function[labels,depths,locations]=ContentsFcn(projectInfoString,options)
    if nargin<2||~isfield(options,'doRefresh')
        doRefresh=false;
    else
        doRefresh=options.doRefresh;
    end


    [~,nameInfo]=strtok(projectInfoString,' ');
    projectName=nameInfo(3:end-1);
    if isempty(projectName)
        error('ContentsFcn() expects projectName in parenthesis.');
    end
    project=oslc.Project.get(projectName);
    if project.isUpdatedList()
        [labels,depths,locations]=project.listCollections();
        return;
    elseif~doRefresh&&isempty(project.itemIds)&&isempty(project.collectionIds)
        doRefresh=true;
    end
    progressMessage=getString(message('Slvnv:oslc:GettingContentsOf',projectName));
    rmiut.progressBarFcn('set',0.5,progressMessage,getString(message('Slvnv:oslc:PleaseWait')));
    myConnection=oslc.connection();
    allCollectionsIds=myConnection.getCollectionsIds(doRefresh);
    if isempty(allCollectionsIds)
        [labels,depths,locations]=project.listAllRequirements(doRefresh);
    else
        [labels,depths,locations]=project.listCollections(allCollectionsIds);
    end
    rmiut.progressBarFcn('delete');
end

function out=ItemIdFcn(project,in,mode)



    if~isempty(in)&&in(1)=='@'
        in=in(2:end);
    end

    if mode

        projectName='';
        if~strncmp(project,'https:',length('https:'))
            catalogInfo=oslc.getCatalog();
            catalogNames=catalogInfo(:,1);
            idx=find(strcmp(catalogNames,project));
            if isempty(idx)
                out=in;
                return;
            end
            projectName=catalogNames(idx);
            proj=oslc.Project.get(projectName);
            project=[proj.queryBase,'(',projectName,')'];
        end
        if isempty(in)
            out=project;
        else
            if all(double('0')<=in&in<=double('9'))

                if isempty(projectName)
                    projectName=loc_getFromParenthesis(project);
                end
                req=oslc.getReqItem(in,projectName);
                out=[req.resource,' (',in,')'];
            else
                out=in;
            end
        end
    else

        if isempty(in)
            value=loc_getFromParenthesis(project);
            if isempty(value)
                out=project;
            else
                out=value;
            end
        else
            value=loc_getFromParenthesis(in);
            if isempty(value)
                out=in;
            else
                out=value;
            end
        end
    end

    function inParenthesis=loc_getFromParenthesis(inputStr)
        matched=regexp(inputStr,'\S+\s\((.+)\)','tokens');
        if isempty(matched)
            inParenthesis='';
        else
            inParenthesis=matched{1}{1};
        end
    end
end

function[tf,linkTargetInfo]=BacklinkCheckFcn(mwSourceArtifact,mwItemId,reqDoc,reqId)
    moduleId=strtok(reqDoc);
    reqId=strtok(reqId);
    [tf,linkTargetInfo]=oslc.checkIncomingLink(mwSourceArtifact,mwItemId,moduleId,reqId);
end

function[linkUrl,linkLabel]=BacklinkInsertFcn(reqDoc,reqId,mwSourceArtifact,mwItemId,mwDomain)
    shorterMwName=slreq.uri.getShortNameExt(mwSourceArtifact);
    mwItemStruct=struct('domain',mwDomain,'artifactUri',shorterMwName,'id',mwItemId);
    [linkUrl,linkLabel]=slreq.connector.getMwItemUrlAndLabel(mwItemStruct);
    reqStruct.resource=strtok(reqId);
    reqStruct.projectName=getProjectName(reqDoc);
    success=oslc.addLinkFromResource(reqStruct,linkUrl,linkLabel);
    if~success
        linkUrl='';
    end

    function projName=getProjectName(reqDoc)

        matched=regexp(reqDoc,'\(([^)]+)\)','tokens');
        if~isempty(matched)
            projName=matched{1}{1};
        else

            catalog=oslc.getCatalog();
            matchForProjectURL=regexp(reqDoc,'projectURL=([^&]+)','tokens');
            if isempty(matchForProjectURL)
                projName=oslc.Project.currentProject();
            else
                projURL=urldecode(matchForProjectURL{1}{1});
                catalogIdx=find(strcmp(catalog(:,3),projURL),1);
                if isempty(catalogIdx)
                    projName=oslc.Project.currentProject();
                else
                    projName=catalog{catalogIdx,1};
                end
            end
        end
    end
end

function success=BacklinkDeleteFcn(reqDoc,reqId,mwSourceArtifact,mwItemId)%#ok<INUSD>
    rmiut.warnNoBacktrace('Illegal attempt to delete link in DNG');
    success=false;
end

function[countRemoved,countChecked]=BacklinksCleanupFcn(reqDoc,mwSourceArtifact,linksData,doSaveBeforeCleanup)%#ok<INUSD>
    countChecked=0;
    countRemoved=0;
end

