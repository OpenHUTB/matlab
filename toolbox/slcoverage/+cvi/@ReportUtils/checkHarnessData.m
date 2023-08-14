function[isHarnessData,topModelName,rootId,errmsg,ownerModel]=checkHarnessData(covdata)




    try
        isHarnessData=false;
        topModelName='';
        rootId=[];
        errmsg='';
        ownerModel='';


        SlCov.ContextGuard.resetUpdateDataIdxGuard(covdata);

        modelcovId=cvi.ReportUtils.getModelCovId(covdata);


        [ownerModelOnModel,ownerModelOnData]=getOwnerInfo(covdata,modelcovId);

        if isempty(ownerModelOnModel)&&isempty(ownerModelOnData)
            return;
        end

        if contains(ownerModelOnData,'notUnique')
            ownerModel=[];
        elseif~isempty(ownerModelOnData)
            ownerModel=ownerModelOnData;
        else
            ownerModel=ownerModelOnModel;
        end
        if isempty(ownerModel)

            return;
        end
        isHarnessData=true;
        openedHarnessModel=hasHarnessOpen(ownerModel,covdata,modelcovId);
        if~isBlockHarnessData(covdata)
            [topModelName,rootId,errmsg]=checkBDHarness(covdata,modelcovId,openedHarnessModel);
        else
            [topModelName,rootId,errmsg]=checkBlockHarness(covdata,modelcovId,openedHarnessModel,ownerModel);
        end
        if isempty(ownerModel)
            ownerModel=topModelName;
        end
    catch MEx
        rethrow(MEx);
    end
end

function[topModelName,rootId,errmsg]=checkBDHarness(covdata,modelcovId,openedHarnessModel)
    rootId=covdata.rootID;
    errmsg=[];
    topModelName=[];

    if isempty(modelcovId)
        return;
    end
    topModelcovId=cv('get',modelcovId,'.topModelcovId');

    if~isempty(topModelcovId)&&...
        topModelcovId~=0&&...
        cv('ishandle',topModelcovId)
        thisTopModelName=SlCov.CoverageAPI.getModelcovName(topModelcovId);



        if~strcmpi(thisTopModelName,openedHarnessModel)

            if cv('get',modelcovId,'.topModelcovId')~=modelcovId
                cv('set',modelcovId,'.topModelcovId',0);
            end
        end
    end


    if covdata.isAtomicSubsystemCode()
        topModelName=covdata.getAnalyzedModelForATS();
    else
        topModelName=covdata.modelinfo.analyzedModel;
    end


    [~,~,status]=cvi.ReportUtils.checkModelLoaded(modelcovId);
    if status==0
        errmsg=message('Slvnv:simcoverage:cvhtml:IncompatibleModel',openedHarnessModel,thisModelName);
        return;
    end
    cvi.TopModelCov.checkModelConistency(modelcovId);
end



function[topModelName,rootId,errmsg]=checkBlockHarness(covdata,modelcovId,openedHarnessModel,ownerModel)
    topModelName=[];
    rootId=covdata.rootID;
    errmsg=[];


    mapToHarness=false;
    if~isempty(openedHarnessModel)
        analyzedBlock=[openedHarnessModel,covdata.modelinfo.analyzedModel(strfind(covdata.modelinfo.analyzedModel,'/'):end)];
        mapToHarness=~isempty(analyzedBlock)&&isOpen(analyzedBlock);
        if mapToHarness
            [~,harnessModelOnData]=getHarnessInfo(covdata,modelcovId);


            if~strcmpi(openedHarnessModel,harnessModelOnData)&&...
                ~covdata.canHarnessMapBackToOwner()
                mapToHarness=false;
            end
        end
    end


    if mapToHarness
        topModelName=openedHarnessModel;
        thisTopModelName=SlCov.CoverageAPI.getModelcovName(modelcovId);


        openedHarnessModelMangled=SlCov.CoverageAPI.mangleModelcovName(openedHarnessModel,SlCov.CovMode.Normal,covdata.dbVersion);
        matchingModelcovId=SlCov.CoverageAPI.findModelcovMangled(openedHarnessModelMangled);
        assert(numel(matchingModelcovId)<2,'Two harness models with the same name');

        if~strcmpi(thisTopModelName,openedHarnessModel)&&...
            ~isempty(matchingModelcovId)

            newRootId=cv('RootsIn',matchingModelcovId);
            res=isequal(cv('get',rootId,'.checksum'),cv('get',newRootId,'.checksum'));
            if~res
                errmsg=message('Slvnv:simcoverage:cvhtml:IncompatibleModel',openedHarnessModel,ownerModel);
                return;
            end
            if covdata.id==0
                covdata.setRootId(newRootId);
            else
                testId=covdata.id;

                if cv('get',modelcovId,'.currentTest')==testId
                    cv('set',modelcovId,'.currentTest',0);
                end

                cv('RootRemoveTest',rootId,testId);
                cv('RootAddTest',newRootId,testId);
                cv('set',testId,'.modelcov',matchingModelcovId);
            end
            rootId=newRootId;
            modelcovId=matchingModelcovId;
        end
        if covdata.id~=0

            cv('set',modelcovId,'.currentTest',covdata.id);
        end


        cv('set',modelcovId,'.activeRoot',rootId);
        status=cvi.TopModelCov.updateModelHandles(modelcovId,openedHarnessModel,false);
        if status==0
            errmsg=message('Slvnv:simcoverage:cvhtml:IncompatibleModel',openedHarnessModel,ownerModel);
            return;
        end
        cvi.TopModelCov.checkModelConistency(modelcovId);

    elseif isOpen(ownerModel)
        modelCovId=cvi.ReportUtils.getModelCovId(covdata);

        if~isempty(modelCovId)
            modelName=SlCov.CoverageAPI.getModelcovName(modelcovId);

            if~strcmpi(modelName,ownerModel)

                newRootId=cvi.TopModelCov.moveHarnessTest(modelcovId,ownerModel,covdata);

                if isempty(newRootId)
                    harnessModel=cv('get',modelcovId,'.harnessModel');
                    errmsg=message('Slvnv:simcoverage:cvhtml:IncompatibleModel',ownerModel,harnessModel);
                    return;
                end
                rootId=newRootId;
            else
                status=cvi.TopModelCov.updateModelHandles(modelcovId,ownerModel);
                if status==0
                    harnessModel=cv('get',modelcovId,'.harnessModel');
                    errmsg=message('Slvnv:simcoverage:cvhtml:IncompatibleModel',ownerModel,harnessModel);
                    return;
                end
            end
        end
        topModelName=ownerModel;
    end
end

function[harnessName,syncHarness]=hasHarnessOpen(modelName,covdata,modelcovId)
    harnessName='';
    syncHarness=true;
    if isOpen(modelName)
        [~,harnessModelOnData]=getHarnessInfo(covdata,modelcovId);
        res=Simulink.harness.internal.getActiveHarness(modelName);

        if isempty(res)
            return;
        end
        if contains(harnessModelOnData,'notUnique')
            harnessName=res(1).name;
        else
            for idx=1:numel(res)
                if strcmpi(res(idx).name,harnessModelOnData)
                    harnessName=harnessModelOnData;
                end
            end
        end
    end
end

function res=isBlockHarnessData(covdata)
    res=~isempty(cv('GetRootPath',covdata.rootID));
end


function res=isOpen(modelName)
    res=true;
    try
        get_param(modelName,'name');
    catch MEx %#ok<NASGU>
        res=false;
    end
end

function[ownerModelOnModel,ownerModelOnData]=getOwnerInfo(cvd,modelcovId)
    mi=cvd.getRawModelInfo();
    ownerModelOnData=mi.ownerModel;
    ownerModelOnModel=cv('get',modelcovId,'.ownerModel');
end


function[harnessModelOnModel,harnessModelOnData]=getHarnessInfo(cvd,modelcovId)
    mi=cvd.getRawModelInfo();
    harnessModelOnData=mi.harnessModel;
    harnessModelOnModel=cv('get',modelcovId,'.harnessModel');
end
