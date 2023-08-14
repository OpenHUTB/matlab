function[toHighlight,informerObj,sfInstanceStruct]=SFLibInstanceHighlightingChecks(blockH)



    toHighlight=true;
    informerObj=[];
    sfInstanceStruct=[];

    modelH=get_param(bdroot(blockH),'Handle');
    covColorData=get_param(modelH,'covColorData');
    refBlockH=get_param(get_param(blockH,'ReferenceBlock'),'Handle');

    if isempty(covColorData)||~isfield(covColorData,'sfLinkInfo')||isempty(covColorData.sfLinkInfo)
        toHighlight=false;
        return;
    end

    instanceList=[covColorData.sfLinkInfo.instanceH];
    instIdx=find(instanceList==blockH);

    if isempty(instIdx)
        toHighlight=false;
        return;
    end

    if length(instIdx)>1
        error(message('Slvnv:simcoverage:cvrefreshsfinstancecov:ErrorCalculating'));
    end

    sfInstanceStruct=covColorData.sfLinkInfo(instIdx);



    if(refBlockH~=sfInstanceStruct.refBlockH)
        toHighlight=false;
        return;
    end

    modelCovId=get_param(modelH,'CoverageId');

    if(modelCovId==0)



        modelCovId=cv('get',sfInstanceStruct.cvIds(1),'.modelcov');
    end



    topModelCovId=cv('get',modelCovId,'.topModelcovId');

    if(topModelCovId>0)
        informerObj=cvi.Informer.getInstance(topModelCovId);
    else
        informerObj=cvi.Informer.getInstance(modelCovId);
    end
    if isempty(informerObj)
        toHighlight=false;
    end
end