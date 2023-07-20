function[varargout]=docCheckCallback(command,varargin)



    persistent sessionId links;

    if isempty(sessionId)
        sessionId=' ';
    end






    switch(command)
    case 'store'
        report=varargin{1};
        sessionId=report.sessionId;
        links=report.links;





    case 'session'
        if nargout>0
            varargout{1}=sessionId;
        end

    case 'fix'
        item=varargin{1};
        issue=varargin{2};
        args=varargin{3:end};
        match=strcmp({links.itemname},item);
        if isempty(links(match).details)
            errordlg(getString(message('Slvnv:rmiref:docCheckCallback:ItemIsAlreadyFixed',item)));
            return;
        elseif~strcmp(links(match).issue,issue)
            errordlg(getString(message('Slvnv:rmiref:docCheckCallback:MismatchedIssueIn',item,links(match).issue)));
            return;
        end
        if~any(match)
            error(message('Slvnv:rmiref:docCheckCallback:ItemNotFound',item));
        end
        switch issue
        case rmiref.DocChecker.UNRESOLVED_MODEL
            fixModel(links,match,args);
        case rmiref.DocChecker.UNRESOLVED_OBJECT
            fixObject(links,match);
        otherwise
            error(message('Slvnv:rmiref:docCheckCallback:UnsupportedIssue',issue));
        end

    case 'viewInDocument'
        cbSession=varargin{1};
        index=varargin{2};

        if~isSessionValid(cbSession,sessionId)
            return;
        end

        links(index).viewInDocument();

    case 'viewInSimulink'
        cbSession=varargin{1};
        index=varargin{2};

        if~isSessionValid(cbSession,sessionId)
            return;
        end

        links(index).viewInSimulink();

    otherwise,
        error(message('Slvnv:rmiref:docCheckCallback:UnknownMethod',method));
    end
end


function out=isSessionValid(sessionId,expectedId)
    if strcmp(sessionId,expectedId)
        out=true;
    else
        out=false;
        errordlg(getString(message('Slvnv:rmiref:docCheckCallback:ReportOutOfDateMustBeRegenerated')),...
        getString(message('Slvnv:rmiref:docCheckCallback:OutdatedSession')));
    end
end

function fixed=fixModel(allLinks,match,args)
    myLink=allLinks(match);
    invalidModel=myLink.details;
    matches=strcmp({allLinks.details},invalidModel);
    matchedLinks=allLinks(matches);
    if length(matchedLinks)>1
        reply=questdlg({[rmiref.DocChecker.UNRESOLVED_MODEL,': ',invalidModel,'.'],...
        getString(message('Slvnv:rmiref:docCheckCallback:ThereAreNRefsToModel',length(matchedLinks))),...
        '',...
        getString(message('Slvnv:rmiref:docCheckCallback:FixByChoosingModel')),...
        getString(message('Slvnv:rmiref:docCheckCallback:AlternativelyClickResetAll'))},...
        getString(message('Slvnv:rmiref:docCheckCallback:ProblemWithLinkFromDocument')),...
        getString(message('Slvnv:rmiref:docCheckCallback:FixAll')),...
        getString(message('Slvnv:rmiref:docCheckCallback:ResetAll')),...
        getString(message('Slvnv:rmiref:docCheckCallback:Cancel')),...
        getString(message('Slvnv:rmiref:docCheckCallback:FixAll')));
    else
        reply=questdlg({[rmiref.DocChecker.UNRESOLVED_MODEL,': ',invalidModel,'.'],...
        getString(message('Slvnv:rmiref:docCheckCallback:ThereAreNoMoreLinks')),...
        '',...
        getString(message('Slvnv:rmiref:docCheckCallback:FixByChoosingModel')),...
        getString(message('Slvnv:rmiref:docCheckCallback:AlternativelyClickReset'))},...
        getString(message('Slvnv:rmiref:docCheckCallback:ProblemWithLinkFromDocument')),...
        getString(message('Slvnv:rmiref:docCheckCallback:Fix')),...
        getString(message('Slvnv:rmiref:docCheckCallback:Reset')),...
        getString(message('Slvnv:rmiref:docCheckCallback:Cancel')),...
        getString(message('Slvnv:rmiref:docCheckCallback:Fix')));
    end
    if isempty(reply)
        reply=getString(message('Slvnv:rmiref:docCheckCallback:Cancel'));
    end
    switch reply
    case{getString(message('Slvnv:rmiref:docCheckCallback:Fix')),getString(message('Slvnv:rmiref:docCheckCallback:FixAll'))}
        newModelPath=rmiref.DocChecker.promptModel();
        if~isempty(newModelPath)
            for i=1:length(matchedLinks)
                thisLink=matchedLinks(i);
                fixed=thisLink.updateModel(newModelPath,args);
                if fixed
                    thisLink.issue='';
                    thisLink.details='';
                end
            end
        end
    case{getString(message('Slvnv:rmiref:docCheckCallback:Reset')),getString(message('Slvnv:rmiref:docCheckCallback:ResetAll'))}
        for i=1:length(matchedLinks)
            thisLink=matchedLinks(i);
            fixed=thisLink.restore();
            if fixed
                thisLink.issue='';
                thisLink.details='';
            end
        end
    otherwise
        fixed=false;
    end
end


function fixed=fixObject(allLinks,match)

    myLink=allLinks(match);
    [invalidObject,label_info]=strtok(myLink.details);
    allDetails=strtok({allLinks.details});
    matches=strcmp(allDetails,invalidObject);
    allMatches=allLinks(matches);
    if length(invalidObject)>10
        object_info=[getString(message('Slvnv:rmiref:docCheckCallback:StoredIdEndsWith')),' ...',invalidObject(end-10:end),'.'];
    else
        object_info=[getString(message('Slvnv:rmiref:docCheckCallback:StoredIdEndsWith')),': ',invalidObject,'.'];
    end
    if length(label_info)>4&&label_info(2)=='('&&label_info(end)==')'
        label_info=label_info(3:end-1);
    end
    if length(allMatches)>1
        reply=questdlg({getString(message('Slvnv:rmiref:docCheckCallback:ObjectIdIsNotFound',myLink.model)),...
        getString(message('Slvnv:rmiref:docCheckCallback:LinkLabel',label_info)),...
        object_info,...
        ' ',...
        getString(message('Slvnv:rmiref:docCheckCallback:ClickNextToLocate',num2str(length(allMatches)))),...
        getString(message('Slvnv:rmiref:docCheckCallback:DeleteTheseReferences')),...
        getString(message('Slvnv:rmiref:docCheckCallback:AlternativelyClickReset'))},...
        getString(message('Slvnv:rmiref:docCheckCallback:ProblemWithLinkFromDocument')),...
        getString(message('Slvnv:rmiref:docCheckCallback:OK')),...
        getString(message('Slvnv:rmiref:docCheckCallback:ResetAll')),...
        getString(message('Slvnv:rmiref:docCheckCallback:Next')),...
        getString(message('Slvnv:rmiref:docCheckCallback:OK')));
    else
        reply=questdlg({getString(message('Slvnv:rmiref:docCheckCallback:ObjectIdIsNotFound',myLink.model)),...
        getString(message('Slvnv:rmiref:docCheckCallback:LinkLabel',label_info)),...
        object_info,...
        ' ',...
        getString(message('Slvnv:rmiref:docCheckCallback:DeleteThisReference')),...
        getString(message('Slvnv:rmiref:docCheckCallback:AlternativelyClickReset'))},...
        getString(message('Slvnv:rmiref:docCheckCallback:ProblemWithLinkFromDocument')),...
        getString(message('Slvnv:rmiref:docCheckCallback:OK')),...
        getString(message('Slvnv:rmiref:docCheckCallback:Reset')),...
        getString(message('Slvnv:rmiref:docCheckCallback:OK')));
    end
    if isempty(reply)
        reply=getString(message('Slvnv:rmiref:docCheckCallback:OK'));
    end

    switch reply
    case{getString(message('Slvnv:rmiref:docCheckCallback:Reset')),getString(message('Slvnv:rmiref:docCheckCallback:ResetAll'))}
        for i=1:length(allMatches)
            thisLink=allMatches(i);
            fixed=thisLink.restore();
            if fixed
                thisLink.issue='';
                thisLink.details='';
            end
        end
    case getString(message('Slvnv:rmiref:docCheckCallback:Next'))
        otherMatches=matches&~match;
        otherLinks=allLinks(otherMatches);

        findOther=find(otherMatches);
        findThis=find(match);
        findAfter=find(findOther>findThis);
        if isempty(findAfter)
            otherLinks(1).viewInDocument();
        else
            otherLinks(findAfter(1)).viewInDocument();
        end
        fixed=false;
    otherwise
        fixed=false;
    end
end
