function[slHs,sfHs]=getLinkedHandles(modelH,filters)




    if ischar(modelH)
        [~,slDiagram]=fileparts(modelH);
    else
        [~,slDiagram]=rmisl.modelFileParts(modelH);
    end

    artifactUri=get_param(modelH,'FileName');
    rdata=slreq.data.ReqData.getInstance();
    linkSet=rdata.getLinkSet(artifactUri);
    if isempty(linkSet)
        allIDs={};
    else
        linkedItems=linkSet.getLinkedItems();
        allIDs=cell(size(linkedItems));
        for i=1:length(allIDs)
            allIDs{i}=linkedItems(i).id;
        end
    end





    surrogateCheck=doCheckSurrogateLinks(slDiagram);
    filterCheck=isTagFilterEnabled(filters);

    if filterCheck||surrogateCheck
        skipIdx=false(size(allIDs));
        srcStruct.domain='linktype_rmi_simulink';
        srcStruct.artifact=get_param(modelH,'FileName');
        for i=1:length(allIDs)
            srcStruct.id=allIDs{i};







            links=slreq.utils.getLinks(srcStruct);
            if isempty(links)
                skipIdx(i)=true;
                continue;
            else
                reqs=slreq.utils.linkToStruct(links);
            end

            if isempty(reqs)
                skipIdx(i)=true;
                continue;
            end

            if surrogateCheck
                if~any([reqs.linked])
                    skipIdx(i)=true;
                    continue;
                end
            end

            if filterCheck
                reqs=rmi.filterTags(reqs,filters.tagsRequire,filters.tagsExclude);
                if isempty(reqs)
                    skipIdx(i)=true;
                    continue;
                end
            end
        end
        if any(skipIdx)
            allIDs(skipIdx)=[];
        end
    end

    [slHs,sfHs]=getHandles(modelH,slDiagram,allIDs);




    slHs=unique(slHs);

end

function yesno=isTagFilterEnabled(filters)
    yesno=~isempty(filters)&&filters.enabled&&...
    (~isempty(filters.tagsRequire)||~isempty(filters.tagsExclude));
end

function yesno=doCheckSurrogateLinks(slModel)
    if rmi.settings_mgr('get','filterSettings','linkedOnly')
        try
            get_param(slModel,'reqMgrSettings');
            checkSurrogateLinks=rmipref('KeepSurrogateLinks');
            if isempty(checkSurrogateLinks)
                yesno=true;
            else
                yesno=checkSurrogateLinks;
            end
        catch Mex %#ok<NASGU>
            yesno=false;
        end
    else
        yesno=false;
    end
end

function[slHs,sfHs]=getHandles(modelH,slDiagram,allIDs)
    slHs=[];
    sfHs=[];



    modelName=get_param(modelH,'Name');
    if strcmp(modelName,slDiagram)

        mainModelName=modelName;
        harnessID='';
    else

        [mainModelName,harnessID]=strtok(slDiagram,':');
    end
    for i=1:length(allIDs)
        if rmisl.isHarnessIdString(allIDs{i})
            continue;
        end


        if any(allIDs{i}=='~')
            continue;
        end

        sid=[mainModelName,allIDs{i}];


        [sid,rest]=strtok(sid,'.');
        if~isempty(harnessID)

            obj=Simulink.ID.getHandle(sid);
            if~isa(obj,'Stateflow.Object')
                obj=get_param(obj,'Object');
            end
            sid=Simulink.harness.internal.sidmap.getOwnerObjectSIDInHarness(obj);
            if isempty(sid)
                continue;
            end
        end
        if~isempty(rest)

            sigbH=protectedSidToHandle(sid);
            if isempty(sigbH)
            elseif~any(slHs==sigbH)
                slHs(end+1,1)=sigbH;%#ok<AGROW>
            end
            continue;
        end

        objH=protectedSidToHandle(sid);
        if~isempty(objH)
            if isa(objH,'double')
                slHs(end+1,1)=objH;%#ok<AGROW>
            elseif isa(objH,'Stateflow.Object')
                sfHs(end+1,1)=objH.Id;%#ok<AGROW>
            else
                warning('Invalid type: %s',class(objH));
            end
        end
    end
end

function handle=protectedSidToHandle(sid)
    try
        handle=Simulink.ID.getHandle(sid);
    catch ME %#ok<NASGU> 
        handle=[];
    end
end

