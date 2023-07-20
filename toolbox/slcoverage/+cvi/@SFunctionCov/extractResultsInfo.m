function sfcnCovRes=extractResultsInfo(allTests,blockCvIds)






    sfcnCovRes=struct(...
    'allSFcnRes',{[]},...
    'covId2InstanceInfo',{containers.Map('KeyType','double','ValueType','any')},...
    'filteredInstanceSet',{containers.Map('KeyType','char','ValueType','any')}...
    );


    covdata=allTests{1};


    if nargin<2
        cvId=cv('get',covdata.rootId,'.topSlsf');
        [~,blockCvIds,~]=cv('DfsOrder',cvId);
    end


    if isempty(blockCvIds)||isempty(covdata.sfcnCovData)
        return
    end


    filteredInstances=covdata.sfcnCovData.FilteredInstances;
    if~isempty(filteredInstances)
        sfcnCovRes.filteredInstanceSet=containers.Map(...
        filteredInstances(:),num2cell(true(numel(filteredInstances),1)));
    end

    if hasData(covdata.sfcnCovData)


        blkH=cv('get',blockCvIds,'.handle');
        idx=find(~ishandle(blkH));
        blockCvIds(idx)=[];
        blkH(idx)=[];
        if isempty(blockCvIds)||isempty(blkH)

            return
        end



        sfcnH=find_system(blkH,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks','on','LookUnderMasks','all','type','block','blocktype','S-Function');
        if isempty(sfcnH)

            return
        end

        harnessModel=covdata.modelinfo.harnessModel;
        ownerBlock=covdata.modelinfo.ownerBlock;
        ownerModel=covdata.modelinfo.ownerModel;
        blkSID=cellstr(Simulink.ID.getSID(sfcnH));


        numData=numel(allTests);
        sfcnCovRes.allResults=cell(1,numData);
        for ii=1:numData
            fcnNameToRes=containers.Map('KeyType','char','ValueType','any');
            if~isempty(allTests{ii}.sfcnCovData)
                sfcnData=allTests{ii}.sfcnCovData.getAll();
                for jj=1:numel(sfcnData)
                    fcnNameToRes(sfcnData(jj).Name)=checkHarnessInstanceInfo(sfcnData(jj),harnessModel,ownerBlock,ownerModel);
                end
            end
            sfcnCovRes.allResults{ii}=fcnNameToRes;
        end

        sfcnNames=sfcnCovRes.allResults{1}.keys();

        for ii=1:numel(sfcnNames)


            sfcnResMap=sfcnCovRes.allResults{1};
            resObj=sfcnResMap(sfcnNames{ii});

            instSID=resObj.getInstanceSIDs();
            [sid,ia,ib]=intersect(instSID,blkSID);
            if isempty(sid)

                continue
            end

            numInst=numel(sid);
            for jj=1:numInst
                iInfoStruct=cvi.SLCustomCodeCov.newInstanceResultsInfoStruct(resObj.Name);
                iInfoStruct.resultIdx=ii;
                iInfoStruct.instanceIdx=ia(jj);
                hIdx=find(blkH==sfcnH(ib(jj)));
                if~isempty(hIdx)
                    sfcnCovRes.covId2InstanceInfo(blockCvIds(hIdx))=iInfoStruct;
                end
            end
        end
    end

    function sfcnData=checkHarnessInstanceInfo(sfcnData,harnessModel,ownerBlock,ownerModel)
        if isempty(harnessModel)
            return;
        end
        try

            res=Simulink.harness.internal.getActiveHarness(ownerModel);
            if~isempty(res)
                return
            end
        catch

            return
        end

        sfcnData=sfcnData.clone();

        for ii=1:sfcnData.getNumInstances()
            res=sfcnData.getInstanceResults(ii);
            instanceName=res.instance.name;
            if startsWith(instanceName,harnessModel)==1
                idx=strfind(instanceName,'/');
                originalInstanceName=[ownerBlock,instanceName(idx(end):end)];
                res.instance.name=originalInstanceName;
                try
                    res.instance.sid=Simulink.ID.getSID(res.instance.name);
                catch Mex

                    Mex;%#ok<VUNUS> 
                end
            end
        end


