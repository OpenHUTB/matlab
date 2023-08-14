


function result=dngConfigMgr(method,varargin)

    switch method

    case 'server'

        result=oslc.config.getAllForProject();

    case 'linked'

        result=oslc.config.getLinked();

    case 'report'

        known=oslc.config.getAllForProject();
        linked=oslc.config.getLinked();
        result=makeReportPage(linked,known);

    case 'select'


        currentType=varargin{1};
        currentId=varargin{2};
        known=oslc.config.getAllForProject();
        result=makeSelectionPage(currentType,currentId,known);

    case 'update'


        oldConfigId=varargin{1};
        newConfigId=varargin{2};
        result=updateLinkTargets(oldConfigId,newConfigId);

    case 'save'

        artifactToSave=varargin{1};
        savedToFile=slreq.saveLinks(artifactToSave);
        if~isempty(savedToFile)
            result=sprintf('<br/><center>%s</center><br/>\n',...
            hyperlinkToReport(getString(message('Slvnv:oslc:UpdatedRefresh'))));
        else
            result=getString(message('Slvnv:oslc:UpdatedNothing'));
        end

    otherwise



        error('method %s is not supported',method);
    end
end




function html=updateLinkTargets(oldId,newId)
    html='';



    oldId=strrep(oldId,'/','%2F');
    newId=strrep(newId,'/','%2F');

    linkSets=slreq.data.ReqData.getInstance.getLoadedLinkSets();
    for i=1:numel(linkSets)
        linkSet=linkSets(i);
        count=linkSet.updateDocUri(oldId,newId);
        if count>0
            [~,aName,aExt]=fileparts(linkSet.artifact);
            artifactName=[aName,aExt];
            reportCount=getString(message('Slvnv:oslc:UpdatedNLinks',num2str(count),artifactName));
            hLinkToSave=hyperlinkToSaveLinks(artifactName);
            html=sprintf('%s (%s)<br/>\n',reportCount,hLinkToSave);
        end
    end

    if isempty(html)
        html=getString(message('Slvnv:oslc:UpdatedNothing'));
    else
        html=sprintf('%s<br/><center>%s</center><br/>\n',html,...
        hyperlinkToReport(getString(message('Slvnv:oslc:UpdatedRefresh'))));
    end
end


function result=makeSelectionPage(currentType,currentId,available)

    origIdInfo='';
    types=cell(0,1);

    switch currentType

    case 'changeset'
        isMatch=strcmp(currentId,available.knownChangesets(:,4));
        if any(isMatch)
            changesetName=available.knownChangesets{isMatch,2};
            url=available.knownChangesets{isMatch,1};
            origIdInfo=sprintf('<a href="%s">%s</a> (changeset)',url,changesetName);
            choiceIds=[...
            available.knownStreams(:,4);...
            available.knownBaselines(:,4);...
            available.knownChangesets(~isMatch,4)];
            choiceNames=[...
            available.knownStreams(:,2);...
            available.knownBaselines(:,2);...
            available.knownChangesets(~isMatch,2)];
            types=[...
            available.knownStreams(:,3);...
            available.knownBaselines(:,3);...
            available.knownChangesets(~isMatch,3)];
        end

    case 'stream'
        isMatch=strcmp(currentId,available.knownStreams(:,4));
        if any(isMatch)
            streamName=available.knownStreams{isMatch,2};
            url=available.knownStreams{isMatch,1};
            origIdInfo=sprintf('<a href="%s">%s</a> (stream)',url,streamName);
            choiceIds=[...
            available.knownStreams(~isMatch,4);...
            available.knownBaselines(:,4);...
            available.knownChangesets(:,4)];
            choiceNames=[...
            available.knownStreams(~isMatch,2);...
            available.knownBaselines(:,2);...
            available.knownChangesets(:,2)];
            types=[...
            available.knownStreams(~isMatch,3);...
            available.knownBaselines(:,3);...
            available.knownChangesets(:,3)];
        end

    case 'baseline'
        isMatch=strcmp(currentId,available.knownStreams(:,4));
        if any(isMatch)
            streamName=available.knownStreams{isMatch,2};
            url=available.knownStreams{isMatch,1};
            origIdInfo=sprintf('<a href="%s">%s</a> (stream)',url,streamName);
            choiceIds=[...
            available.knownStreams(:,4);...
            available.knownBaselines(~isMatch,4);...
            available.knownChangesets(:,4)];
            choiceNames=[...
            available.knownStreams(:,2);...
            available.knownBaselines(~isMatch,2);...
            available.knownChangesets(:,2)];
            types=[...
            available.knownStreams(:,3);...
            available.knownBaselines(~isMatch,3);...
            available.knownChangesets(:,3)];
        end

    otherwise

    end
    if isempty(origIdInfo)
        origIdInfo=sprintf('%s (%s)',currentId,currentType);
        choiceIds=[...
        available.knownStreams(:,4);...
        available.knownChangesets(:,4)];
        choiceNames=[...
        available.knownStreams(:,2);...
        available.knownChangesets(:,2)];
        types=[...
        available.knownStreams(:,3);...
        available.knownChangesets(:,3)];
    end
    instruction=getString(message('Slvnv:oslc:SelectTargetConfiguration'));
    instructionHeader=sprintf('%s %s',instruction,origIdInfo);
    result=sprintf('<h3>%s</h3>\n<ul>',instructionHeader);
    for i=1:size(choiceIds,1)
        choiceType=types{i};
        result=sprintf('%s<li>%s (%s)</li>\n',...
        result,hyperlinkToUpdateAction(choiceNames{i},currentType,currentId,choiceType,choiceIds{i}),choiceIds{i});
    end
    result=sprintf('%s</ul>\n',result);
end



function result=makeReportPage(linked,known)

    matchedStreams='';
    matchedChangesets='';
    matchedBaselines='';
    unresolved='';

    changesetIds=keys(linked.linkedChangesets);
    for i=1:length(changesetIds)
        id=changesetIds{i};
        linkCount=getString(message('Slvnv:oslc:NLinks',num2str(linked.linkedChangesets(id))));
        match=find(strcmp(known.knownChangesets(:,4),id));
        if isempty(match)
            url=linked.configUrls(id);
            unresolved=sprintf('%s<li>changeset <a href="%s">%s</a> (%s) %s</li>\n',...
            unresolved,url,id,linkCount,hyperlinkToUpdatePage('changeset',id));
        else
            matchedChangesets=sprintf('%s<li><a href="%s">%s</a> (%s) %s</li>\n',...
            matchedChangesets,known.knownChangesets{match,1},known.knownChangesets{match,2},linkCount,hyperlinkToUpdatePage('changeset',id));
        end
    end

    streamIds=keys(linked.linkedStreams);
    for i=1:length(streamIds)
        id=streamIds{i};
        linkCount=getString(message('Slvnv:oslc:NLinks',num2str(linked.linkedStreams(id))));
        match=find(strcmp(known.knownStreams(:,4),id));
        if isempty(match)
            url=linked.configUrls(id);
            unresolved=sprintf('%s<li>stream <a href="%s">%s</a> (%s) %s</li>\n',...
            unresolved,url,id,linkCount,hyperlinkToUpdatePage('stream',id));
        else
            matchedStreams=sprintf('%s<li><a href="%s">%s</a> (%s) %s</li>\n',...
            matchedStreams,known.knownStreams{match,1},known.knownStreams{match,2},linkCount,hyperlinkToUpdatePage('stream',id));
        end
    end

    baselineIds=keys(linked.linkedBaselines);
    for i=1:length(baselineIds)
        id=baselineIds{i};
        linkCount=getString(message('Slvnv:oslc:NLinks',num2str(linked.linkedBaselines(id))));
        match=find(strcmp(known.knownBaselines(:,4),id));
        if isempty(match)
            url=linked.configUrls(id);
            unresolved=sprintf('%s<li>baseline <a href="%s">%s</a> (%s) %s</li>\n',...
            unresolved,url,id,linkCount,hyperlinkToUpdatePage('baseline',id));
        else
            matchedBaselines=sprintf('%s<li><a href="%s">%s</a> (%s) %s</li>\n',...
            matchedBaselines,known.knownBaselines{match,1},known.knownBaselines{match,2},linkCount,hyperlinkToUpdatePage('baseline',id));
        end
    end

    result='';
    if~isempty(matchedChangesets)
        result=sprintf('%s<h3>Linked Changesets</h3>\n<ul>\n%s</ul>\n',result,matchedChangesets);
    end
    if~isempty(matchedStreams)
        result=sprintf('%s<h3>Linked Streams</h3>\n<ul>\n%s</ul>\n',result,matchedStreams);
    end
    if~isempty(matchedBaselines)
        result=sprintf('%s<h3>Linked Baselines</h3>\n<ul>\n%s</ul>\n',result,matchedBaselines);
    end
    if~isempty(unresolved)
        result=sprintf('%s<h3>Unresolved configurations</h3>\n<ul>\n%s</ul>\n',result,unresolved);
    end

end


function hlink=hyperlinkToUpdatePage(type,id)
    hUrl=['https://127.0.0.1:31515/matlab/oslc/configmgr?action=select&type=',type,'&id=',id];
    hLabel=lower(getString(message('Slvnv:oslc:Redirect')));
    hlink=sprintf('<a href="%s">%s</a>',hUrl,hLabel);
end


function hlink=hyperlinkToUpdateAction(label,oldType,oldId,newType,newId)
    oldArg=[oldType,'%2F',oldId];
    newArg=[newType,'%2F',newId];
    hUrl=['https://127.0.0.1:31515/matlab/oslc/configmgr?action=update&old=',oldArg,'&new=',newArg];
    hlink=sprintf('<a href="%s">%s</a>',hUrl,label);
end


function hlink=hyperlinkToSaveLinks(artifact)
    hUrl=['https://127.0.0.1:31515/matlab/oslc/configmgr?action=save&artifact=',artifact];
    label=lower(getString(message('Slvnv:slreq:Save')));
    hlink=sprintf('<a href="%s">%s</a>',hUrl,label);
end

function hlink=hyperlinkToReport(label)
    hUrl='https://127.0.0.1:31515/matlab/oslc/configmgr?action=report';
    hlink=sprintf('<a href="%s">%s</a>',hUrl,label);
end


