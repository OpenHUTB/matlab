


function html=links(filters)

    if~isempty(filters)&&~isstruct(filters)
        html='<font color="red">ERROR</font>';
        return;
    end

    dataLinkSets=slreq.data.ReqData.getInstance.getLoadedLinkSets();

    html='';
    for i=1:numel(dataLinkSets)
        html=[html,newline,linksToRows(dataLinkSets(i),filters)];%#ok<AGROW>
    end

    titleText=makeTitle(filters);
    header=['<h2>',makeSpaceBefore(titleText),'</h2>'];
    if isfield(filters,'testing')&&filters.testing
        webPageStyle='';
    else
        webPageStyle=oslc.dngStyle();
    end


    configMgr=linkToConfigMgr();

    if~isempty(html)

        colHeadSrcArt=getString(message('Slvnv:oslc:ColHeadSrcArt'));
        colHeadSrcObj=getString(message('Slvnv:oslc:ColHeadSrcObj'));
        colHeadLinkedDoc=getString(message('Slvnv:oslc:ColHeadLinkedDoc'));
        colHeadLinkedVer=getString(message('Slvnv:oslc:ColHeadLinkedVer'));
        colHeadLinkedItem=getString(message('Slvnv:oslc:ColHeadLinkedItem'));

        headerRow=['<tr><th>',makeSpaceBefore(colHeadSrcArt)...
        ,'</th><th>',colHeadSrcObj,'</th><th>',colHeadLinkedDoc,'</th><th>',colHeadLinkedVer,'</th><th>',colHeadLinkedItem,'</th></tr>'];
        html=['<html><head><title>',titleText,'</title>',newline...
        ,webPageStyle,newline,'</head>',newline...
        ,'<body class="claro">',newline...
        ,header,newline...
        ,'<table cellspacing=10>',headerRow,newline...
        ,html,'</table>',newline...
        ,configMgr,newline...
        ,'</body></html>'];
    else
        noLinks=getString(message('Slvnv:oslc:NoLinks'));
        html=['<html><head><title>',titleText,'</title>',newline...
        ,webPageStyle,newline,'</head>',newline...
        ,'<body class="claro">',newline...
        ,header,newline...
        ,'<font color="orange">',makeSpaceBefore(noLinks),'</font>',newline...
        ,configMgr,newline...
        ,'</body></html>'];
    end
end

function html=linkToConfigMgr()
    reportUrl='https://127.0.0.1:31515/matlab/oslc/configmgr?action=report';
    hLabel=getString(message('Slvnv:oslc:ManageLinkedConfigurations'));
    html=sprintf('<blockquote><a href="%s">%s</a></blockquote>',reportUrl,hLabel);
end

function titleText=makeTitle(filters)
    titleText=getString(message('Slvnv:oslc:LinksFromMLSL'));
    if~isempty(filters)
        myFields=fields(filters);
        for i=1:length(myFields)
            name=myFields{i};
            if ischar(filters.(name))
                titleText=[titleText,' ',name,'=',filters.(name)];%#ok<AGROW>
            end
        end
    end
end

function out=makeSpaceBefore(in)
    out=['&nbsp;&nbsp;&nbsp;',in];
end

function rows=linksToRows(dataLinkSet,filters)
    rows='';
    [~,aName,aExt]=fileparts(dataLinkSet.artifact);
    allLinks=dataLinkSet.getAllLinks();
    allConfigurations=slreq.connector.dngConfigMgr('server');
    for i=1:numel(allLinks)
        dataLink=allLinks(i);
        if isempty(filters)||isMatched(dataLink,filters)
            if strcmp(dataLink.destDomain,'linktype_rmi_oslc')
                doc=formatDocField(dataLink.destUri);
                conf=formatConfField(dataLink.destUri,allConfigurations);
            elseif~isempty(dataLink.dest)&&dataLink.dest.isOSLC()
                doc=dataLink.destUri;
                dataReqSet=dataLink.dest.getReqSet();
                conf=formatConfFieldFromConfUri(dataReqSet.getProperty('configUri'),allConfigurations);
                captureDate=strtok(datestr(dataReqSet.modifiedOn));
                conf=[conf,' (',captureDate,')'];%#ok<AGROW>
            else
                doc=dataLink.destUri;
                conf='N/A';
            end
            srcNavLink=linkToSource(dataLink.source);
            if~isempty(dataLink.dest)
                destNavLink=linkToDest(dataLink.dest);
            else
                destNavLink=['<font color="red">',dataLink.destId,'</font>'];
            end
            rows=[rows,'<tr><td>',makeSpaceBefore([aName,aExt]),'</td><td>',srcNavLink,'</td>'...
            ,'<td>',doc,'</td><td>',conf,'</td><td>',destNavLink,'</td></tr>',newline];%#ok<AGROW>
        end
    end
end

function navLink=linkToSource(src)
    navUrl=slreq.connector.getMwItemUrl(src);
    label=slreq.connector.getMwItemLabel(src);
    navLink=sprintf('<a href="%s">%s</a>',navUrl,label);
end

function navLink=linkToDest(dest)
    doc=dest.artifactUri;
    id=dest.artifactId;


    idLengthMax=20;
    idLengthTrim=8;

    if strcmp(dest.domain,'linktype_rmi_oslc')
        navUrl=oslc.getNavURL(doc,id);
        numIdMatch=regexp(id,'\((\d+)\)','tokens');
        if~isempty(numIdMatch)
            label=numIdMatch{1}{1};
        else
            label=rmiut.trimWithDots(id,idLengthMax,[idLengthTrim,idLengthTrim]);
        end
        navLink=sprintf('<a href="%s" target="_blank">%s</a>',navUrl,label);
        return;

    elseif dest.isOSLC()

        destStruct.domain='linktype_rmi_slreq';
        destStruct.artifactUri=dest.getReqSet.filepath;
        destStruct.id=dest.id;
        label=[dest.customId,' (cache)'];

    elseif slreq.data.Requirement.isExternallySourcedReqIF(dest.domain)




        reqSet=dest.getReqSet();
        destStruct.domain='linktype_rmi_slreq';
        destStruct.artifactUri=slreq.uri.getShortNameExt(reqSet.filepath);
        destStruct.id=num2str(dest.sid);

        label=getString(message('Slvnv:reqmgt:LinkSet:updateContents:LocationInDoc',dest.customId,destStruct.artifactUri));

    else

        destStruct.domain=dest.domain;
        destStruct.artifactUri=doc;
        destStruct.id=id;

        doc=rmiut.trimWithDots(id,idLengthMax,[0,2*idLengthTrim]);
        id=rmiut.trimWithDots(id,idLengthMax,[idLengthTrim,idLengthTrim]);
        label=getString(message('Slvnv:reqmgt:LinkSet:updateContents:LocationInDoc',id,doc));
    end

    navUrl=slreq.connector.getMwItemUrl(destStruct);
    navLink=sprintf('<a href="%s">%s</a>',navUrl,label);
end

function doc=formatDocField(docStr)
    if contains(docStr,'projectURL=')
        projMatch=regexp(docStr,'projectURL=([^&]+)&.+\s\(([^)]+)\)','tokens');
        if~isempty(projMatch)

            doc=projMatch{1}{2};
        else

            doc=docStr;
        end
    else
        doc=docStr;
    end
end

function conf=formatConfFieldFromConfUri(confUrl,configurations)
    conf='UNSPECIFIED';
    parts=regexp(confUrl,'/(\w+)/([-\w]+)$','tokens');
    if~isempty(parts)
        type=parts{1}{1};
        id=parts{1}{2};
        label=sprintf('%s (%s)',type,id);
        switch type
        case 'stream'
            isMatch=strcmp(configurations.knownStreams(:,4),id);
            if any(isMatch)
                label=configurations.knownStreams{isMatch,2};
            end
        case 'changeset'
            isMatch=strcmp(configurations.knownChangesets(:,4),id);
            if any(isMatch)
                label=configurations.knownChangesets{isMatch,2};
            end
        case 'baseline'
            isMatch=strcmp(configurations.knownBaselines(:,4),id);
            if any(isMatch)
                label=configurations.knownBaselines{isMatch,2};
            end
        otherwise

        end
        conf=sprintf('<a href="%s">%s</a>',confUrl,label);
    end
end

function conf=formatConfField(resourceBaseUri,configurations)
    conf='UNSPECIFIED';
    confMatch=regexp(resourceBaseUri,'vvc.configuration=([^& ]+)','tokens');
    if isempty(confMatch)
        confMatch=regexp(resourceBaseUri,'oslc_config.context=([^& ]+)','tokens');
    end
    if~isempty(confMatch)
        confUrl=unescape(confMatch{1}{1});
        conf=formatConfFieldFromConfUri(confUrl,configurations);
    end
end

function out=unescape(in)
    out=strrep(in,'%3A',':');
    out=strrep(out,'%2F','/');
end

function tf=isMatched(link,filters)
    tf=false;


    if isfield(filters,'domain')&&~contains(link.destDomain,filters.domain)
        return;
    elseif isfield(filters,'doc')&&~contains(link.destUri,filters.doc)
        return;
    elseif isfield(filters,'id')&&~isMatchedId(link,filters.id)
        return;
    elseif isfield(filters,'type')&&~strcmpi(link.type,filters.type)
        return;
    elseif isfield(filters,'description')&&~contains(link.description,filters.description)
        return;
    elseif isfield(filters,'keyword')&&~contains(link.keywords,filters.keyword)
        return;
    else
        tf=true;
    end
end

function tf=isMatchedId(link,filterId)




    if contains(link.destId,['(',filterId,')'])
        tf=true;
    else
        dest=link.dest;
        if~isempty(dest)&&dest.external
            tf=strcmp(dest.id,filterId);
        else
            tf=false;
        end
    end
end

