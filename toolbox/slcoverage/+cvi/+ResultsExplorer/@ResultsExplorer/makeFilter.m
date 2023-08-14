function status=makeFilter(filterObj,sldvDataFile)




    try
        status=0;
        if ischar(sldvDataFile)
            v=load(sldvDataFile,'sldvData');
            sldvData=v.sldvData;
        else
            sldvData=sldvDataFile;
        end
        if~strcmpi(sldvData.ModelInformation.Name,filterObj.modelName)
            status=1;
            return;
        end
        for oIdx=1:numel(sldvData.Objectives)
            objective=sldvData.Objectives(oIdx);

            if isfield(objective,'codeLnk')&&~isempty(objective.codeLnk)


                continue;
            end

            if strcmpi(objective.status,'Dead Logic')
                modelObject=sldvData.ModelObjects(objective.modelObjectIdx);
                setFilter(true);
            end
        end
        if isfield(sldvData.ModelInformation,'ReplacementModel')
            checkModelRefFilterConsistency;
        end
    catch MEx %#ok<NASGU>
        status=1;
    end


    function setFilter(isAdd)
        ssid=sldvshareprivate('getModelObjectSidForFilter',modelObject);
        objType=lower(objective.type);
        [coveragePtIdx,outcomeIdx]=computeCoveragePtIdxAndOutcomeIdx(objective,modelObject);
        descr=sldvshareprivate('getObjectiveDescrForFilter',ssid,objective);
        addOrRemoveFilterEntryForObjective;


        function addOrRemoveFilterEntryForObjective
            if isAdd
                filterObj.addMetricFilter(ssid,objType,coveragePtIdx,outcomeIdx,1,'dead logic',descr);
            else
                filterObj.addRemoveInstance(ssid,'',coveragePtIdx,outcomeIdx,objType,'remove');
            end
        end
    end


    function[coveragePtIdx,outcomeIdx]=computeCoveragePtIdxAndOutcomeIdx(objective,modelObject)
        switch lower(objective.type)
        case{'decision'}
            coveragePtIdx=objective.coveragePointIdx;
            outcomeIdx=objective.outcomeValue+1;
        case{'condition'}
            coveragePtIdx=objective.coveragePointIdx;
            outcomeIdx=2-objective.outcomeValue;
        case{'mcdc'}
            coveragePtIdx=sldvshareprivate('getMcdcCovObjectiveIndex',sldvData,modelObject,objective);
            outcomeIdx=objective.coveragePointIdx;
        end
    end


    function checkModelRefFilterConsistency




        objInstanceMap=containers.Map('KeyType','char','ValueType','any');
        mcdcMap=containers.Map('KeyType','char','ValueType','any');

        for idx1=1:numel(sldvData.Objectives)
            obj1=sldvData.Objectives(idx1);
            if~any(strcmpi(obj1.type,{'Decision','Condition','MCDC'}))||...
                (isfield(obj1,'codeLnk')&&~isempty(obj1.codeLnk))


                continue;
            end

            mo=sldvData.ModelObjects(obj1.modelObjectIdx);
            sid=sldvshareprivate('getModelObjectSidForFilter',mo);


            objKey=getObjectiveFilterKey(sid,obj1);
            if objInstanceMap.isKey(objKey)
                cc=objInstanceMap(objKey);
                cc{1}=cc{1}+1;
            else
                cc={1,0};
            end


            if strcmpi(obj1.status,'Dead Logic')
                cc{2}=cc{2}+1;
            end
            objInstanceMap(objKey)=cc;

            if strcmpi(obj1.type,'MCDC')






                mcdcKey=getMcdcKeyCovPtIdxOutIdx(sid,obj1,mo);
                if mcdcMap.isKey(mcdcKey)
                    cc=[mcdcMap(mcdcKey),idx1];
                else
                    cc=idx1;
                end
                mcdcMap(mcdcKey)=cc;
            end
        end

        for idx1=1:numel(sldvData.Objectives)
            objective=sldvData.Objectives(idx1);
            if~any(strcmpi(objective.type,{'Decision','Condition'}))||...
                (isfield(objective,'codeLnk')&&~isempty(objective.codeLnk))

                continue;
            end

            modelObject=sldvData.ModelObjects(objective.modelObjectIdx);
            sid=sldvshareprivate('getModelObjectSidForFilter',modelObject);
            objKey=getObjectiveFilterKey(sid,objective);
            cc=objInstanceMap(objKey);
            if cc{2}>0&&cc{1}~=cc{2}


                setFilter(false);
            end
        end

        for mcdcKey=mcdcMap.keys
            mcdcObjIdxs=mcdcMap(mcdcKey{1});



            keepFilterRule=false;
            for mcdcObjIdx=mcdcObjIdxs
                objective=sldvData.Objectives(mcdcObjIdx);
                assert(strcmpi(objective.type,'MCDC'));

                modelObject=sldvData.ModelObjects(objective.modelObjectIdx);
                sid=sldvshareprivate('getModelObjectSidForFilter',modelObject);
                objKey=getObjectiveFilterKey(sid,objective);
                cc=objInstanceMap(objKey);
                if cc{1}==cc{2}
                    keepFilterRule=true;
                    break;
                end
            end

            if~keepFilterRule
                setFilter(false);
            end
        end
    end


    function str=getObjectiveFilterKey(sid,objective)
        str=sprintf('%s_%s_%d_%d',sid,lower(objective.type),...
        objective.coveragePointIdx,...
        objective.outcomeValue);
    end


    function str=getMcdcKeyCovPtIdxOutIdx(sid,objective,modelObject)
        [covPtIdx,outIdx]=computeCoveragePtIdxAndOutcomeIdx(objective,modelObject);
        str=sprintf('%s_%d_%d',sid,covPtIdx,outIdx);
    end
end
