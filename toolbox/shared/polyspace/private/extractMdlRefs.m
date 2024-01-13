function mdlRefList=extractMdlRefs(systemName,stopLevel)

    mdlRefList={};
    if stopLevel==0
        return
    end

    mdlRefSet=containers.Map({'fake'},{false});
    mdlRefSet.remove('fake');

    modelName=bdroot(systemName);
    try
        fcn=@()find_mdlrefs(modelName,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'AllLevels',false);
        [unused,unused1,mdlRefBlks]=evalc('fcn()');%#ok<ASGLU>
    catch Me
        rethrow(Me);
    end

    if~strcmp(modelName,systemName)
        badIdx=[];
        pattern=['^',systemName,'/'];
        for ii=1:numel(mdlRefBlks)
            if isempty(regexp(mdlRefBlks{ii},pattern,'once'))
                badIdx=[badIdx,ii];%#ok<AGROW>
            end
        end
        mdlRefBlks(badIdx)=[];
    end

    for ii=1:numel(mdlRefBlks)
        mdlRefName=get_param(mdlRefBlks{ii},'ModelName');
        mdlRefSet(mdlRefName)=true;
        iFindMdlRefs(mdlRefSet,mdlRefName,1,stopLevel)
    end

    mdlRefList=mdlRefSet.keys();
    mdlRefList=mdlRefList(:);

end


function iFindMdlRefs(mdlRefSet,currModelName,currLevel,stopLevel)

    if currLevel>=stopLevel
        return
    end

    try
        fcn=@()find_mdlrefs(currModelName,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'AllLevels',false);
        [unused,currMdlRefs]=evalc('fcn()');%#ok<ASGLU>
    catch Me
        rethrow(Me);
    end

    currLevel=currLevel+1;
    for ii=1:numel(currMdlRefs)-1
        if~mdlRefSet.isKey(currMdlRefs{ii})
            mdlRefSet(currMdlRefs{ii})=true;
            iFindMdlRefs(mdlRefSet,currMdlRefs{ii},currLevel,stopLevel);
        end
    end

end


