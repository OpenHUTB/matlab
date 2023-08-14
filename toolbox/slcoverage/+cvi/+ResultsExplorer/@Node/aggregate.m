function[agcvd,errmsg]=aggregate(rootNode)




    agcvd=[];
    errmsg='';
    assert(rootNode==rootNode.parentTree.root);
    if isempty(rootNode.children)
        return;
    end
    resultsExplorer=rootNode.parentTree.resultsExplorer;
    [agcvd,errmsg]=rootNode.aggregateData(rootNode.children,resultsExplorer.topModelName);
    if isempty(agcvd)
        return;
    end
    options=resultsExplorer.getOptions;
    fullFileName=fullfile(options.covOutputDir,'active');

    [userTag,userDescr]=getActualTagAndDescr(rootNode);
    rootNode.data=cvi.ResultsExplorer.Data(fullFileName,agcvd);

    if~isempty(userTag)
        rootNode.data.userEditedTag=true;
        rootNode.data.setTag(userTag);
    end

    if~isempty(userDescr)
        rootNode.data.userEditedDescr=true;
        rootNode.data.setDescription(userDescr);
    end

    rootNode.data.needSave=true;
end

function[userTag,userDescr]=getActualTagAndDescr(rootNode)

    userTag='';
    userDescr='';
    if isempty(rootNode.data)
        return;
    end

    if rootNode.data.userEditedTag
        userTag=rootNode.data.getTag();
    end


    if rootNode.data.userEditedDescr
        userDescr=rootNode.data.getDescription();
    end

end