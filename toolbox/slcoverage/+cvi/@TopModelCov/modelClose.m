




function modelClose(modelH)
    try
        cvi.TopModelCov.closeResultsExplorer(modelH);

        allModelcovIds=SlCov.CoverageAPI.findModelcov(getfullname(modelH));



        allTopModelcovIds=cv('get',allModelcovIds,'.topModelcovId');
        badIdx=ismember(allTopModelcovIds(:)',allModelcovIds)&(allTopModelcovIds(:)'~=allModelcovIds);
        allModelcovIds(badIdx)=[];

        for idx=1:numel(allModelcovIds)
            modelcovId=allModelcovIds(idx);
            if~cv('ishandle',modelcovId)
                continue;
            end

            topModelCovId=cv('get',modelcovId,'.topModelcovId');



            if topModelCovId~=0&&cv('ishandle',topModelCovId)&&~isOpen(SlCov.CoverageAPI.getModelcovName(topModelCovId))
                cvi.TopModelCov.closeResultsExplorer(SlCov.CoverageAPI.getModelcovName(topModelCovId));
                cleanUp(topModelCovId);
                topModelCovId=0;
            end

            if topModelCovId==0




                if cv('ishandle',modelcovId)
                    cvi.Informer.close(modelcovId);
                    cleanUp(modelcovId);
                    cvi.TopModelCov.cvResults(modelH,'closeClear');
                end
            elseif modelcovId==topModelCovId
                if cv('ishandle',topModelCovId)
                    cvi.Informer.close(topModelCovId);
                    cvi.TopModelCov.cvResults(cv('get',topModelCovId,'.handle'),'closeClear');







                    cvi.TopModelCov.removeStaleRefenceIds;
                    allCvIds=cv('find','all','.isa',cv('get','default','modelcov.isa'));
                    refModelCovIds=cv('find',allCvIds,'.topModelcovId',topModelCovId);
                    topModelAndRefCvid=unique([topModelCovId,refModelCovIds,cv('get',topModelCovId,'.refModelcovIds')]);

                    topModelAndRefCvid=checkHarnessTest(topModelAndRefCvid,topModelCovId,modelH);


                    topModelAndRefCvid(ismember(topModelAndRefCvid,allModelcovIds([1:idx-1,idx+1:end])))=[];



                    danglingRefCvIds=cv('find','all','modelcov.topModelcovId',topModelCovId);
                    danglingRefCvIds(danglingRefCvIds==topModelCovId)=[];
                    cv('set',danglingRefCvIds,'.topModelcovId',0);

                    cleanUp(topModelAndRefCvid);
                end
            end
        end
    catch MEx
        rethrow(MEx);
    end


    function res=isOpen(name)
        res=false;
        try
            get_param(name,'name');
            res=true;
        catch MEx %#ok<NASGU>

        end


        function cleanUp(allModelcovIds)
            for currModelcovId=allModelcovIds(:)'
                if cv('ishandle',currModelcovId)

                    ownerName=SlCov.CoverageAPI.getModelcovName(currModelcovId);
                    harnessModelIds=cv('find','all','modelcov.ownerModel',ownerName);





                    for idx=1:numel(harnessModelIds)
                        if cv('ishandle',harnessModelIds(idx))
                            cv('ModelClose',harnessModelIds(idx));
                        end
                    end
                    if cv('ishandle',currModelcovId)
                        cv('ModelClose',currModelcovId);
                    end
                end
            end
            cvi.TopModelCov.removeStaleRefenceIds;

            function topModelAndRefCvid=checkHarnessTest(topModelAndRefCvid,topModelCovId,modelH)







                if~strcmpi(SlCov.CoverageAPI.getModelcovName(topModelCovId),get_param(modelH,'name'))
                    topModelAndRefCvid=[];
                    return;
                end

                unitUnderTestModelcovIds=[];

                for idx=1:numel(topModelAndRefCvid)
                    cvid=topModelAndRefCvid(idx);
                    if cv('ishandle',cvid)&&...
                        ~isempty(cv('get',cvid,'.ownerModel'))
                        unitUnderTestModelcovIds=[unitUnderTestModelcovIds,cvid];%#ok<AGROW>
                    end
                end

                if isempty(unitUnderTestModelcovIds)
                    return;
                end


                ownerModel=cv('get',unitUnderTestModelcovIds(1),'.ownerModel');

                if strcmpi(ownerModel,get_param(modelH,'name'))


                    topModelAndRefCvid=unique([topModelAndRefCvid,cv('find','all','modelcov.ownerModel',ownerModel)]);
                    return;
                end


                topModelAndRefCvid=topModelCovId;

                unitUnderTestModelcovIds=unitUnderTestModelcovIds(topModelCovId~=unitUnderTestModelcovIds);


                if isBlockHarness(topModelCovId)
                    ctId=cv('get',topModelCovId,'.currentTest');



                    if~isempty(ctId)&&ctId~=0
                        cvd=cvdata(ctId);
                        compatFeature=strcmpi(cv('Feature','ModelCov Compatibility'),'on');
                        if compatFeature||cvd.canHarnessMapBackToOwner
                            cvi.TopModelCov.moveHarnessTest(topModelCovId,ownerModel,cvd);

                            topModelAndRefCvid=[];
                        end
                    end
                end

                for idx=1:numel(unitUnderTestModelcovIds)
                    currModelcovId=unitUnderTestModelcovIds(idx);
                    modelName=SlCov.CoverageAPI.getModelcovName(currModelcovId);


                    if~SlCov.CoverageAPI.isGeneratedCode(currModelcovId)&&strcmpi(ownerModel,modelName)
                        cvi.TopModelCov.updateModelHandles(currModelcovId,ownerModel);
                        cvi.TopModelCov.checkModelConistency(currModelcovId);
                    end


                    cv('set',currModelcovId,'.topModelcovId',0);



                end


                function res=isBlockHarness(modelcovId)
                    rootId=cv('get',modelcovId,'.rootTree.child');
                    res=~isempty(cv('get',rootId,'.path'));
