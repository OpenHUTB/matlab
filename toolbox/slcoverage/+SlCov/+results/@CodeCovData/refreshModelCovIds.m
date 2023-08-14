



function refreshModelCovIds(this,cvdOrRootId)

    slModelElements=this.CodeTr.getSLModelElements();

    if isempty(slModelElements)
        return
    end


    try
        modelH=get_param(slModelElements(1).sid,'Handle');
    catch
        modelH=0;
    end
    if modelH==0
        for ii=1:numel(slModelElements)
            slModelElements(ii).modelCovId=0;
        end
        return
    end

    isCvd=isa(cvdOrRootId,'cvdata');
    if isCvd
        rootId=cvdOrRootId.rootId;
    else
        rootId=cvdOrRootId;
    end

    if~cv('ishandle',rootId)
        return
    end

    modelcovId=cv('get',rootId','.modelcov');





    cvi.TopModelCov.updateModelHandles(modelcovId,slModelElements(1).name);
    cvId=cv('get',rootId,'.topSlsf');

    [allCvIds,~]=cv('Dfs',cvId);
    allSIDs=cell(size(allCvIds));
    hasErr=false;
    for ii=1:numel(allCvIds)
        try
            allSIDs{ii}=cvi.TopModelCov.getSID(allCvIds(ii));
        catch

            hasErr=true;
            allSIDs{ii}='';
        end
    end

    if hasErr
        warning(message('Slvnv:simcoverage:cvhtml:StructureChanged',this.Name,'','',''));
    end

    allOrigins=reshape(cv('get',allCvIds,'.origin'),size(allSIDs));

    keys=polyspace.internal.strcat_mex({slModelElements.sid},' ',[slModelElements.origin]);
    [~,idx]=ismember(keys,polyspace.internal.strcat_mex(allSIDs,' ',allOrigins));
    for ii=1:numel(slModelElements)
        if idx(ii)==0
            slModelElements(ii).modelCovId=0;
        else
            slModelElements(ii).modelCovId=allCvIds(idx(ii));
        end
    end


