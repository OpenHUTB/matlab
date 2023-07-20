
function newRootId=moveHarnessTest(harnessModelcovId,ownerModel,cvd)







    try
        newRootId=[];
        if nargin<3||isempty(cvd)
            ct=cv('get',harnessModelcovId,'.currentTest');


            if isempty(ct)||ct==0
                return;
            end
            cvd=cvdata(cv('get',harnessModelcovId,'.currentTest'));
        end

        ownerModelMangledName=SlCov.CoverageAPI.mangleModelcovName(ownerModel,SlCov.CovMode.Normal,cvd.dbVersion);
        matching_models=SlCov.CoverageAPI.findModelcovMangled(ownerModelMangledName);
        matching_models=matching_models(matching_models~=harnessModelcovId);

        ownerBlockPath=cv('get',harnessModelcovId,'.ownerBlock');
        allRootIds=cv('RootsIn',harnessModelcovId);
        currentRootId=pickRoot(allRootIds,ownerBlockPath);
        ownerCovPath=getOwnerCovPath(currentRootId,ownerModel,ownerBlockPath);
        oldRootId=[];
        oldModelcovId=[];
        if~isempty(matching_models)
            oldModelcovId=matching_models(1);
            oldRootId=findRoot(oldModelcovId,ownerCovPath);
        end


        if~isempty(oldRootId)

            if isCompatibleRoots(oldRootId,currentRootId)

                allTests=cv('TestsIn',currentRootId);
                addTests(oldRootId,allTests);
                status=adjustRoot(oldRootId,oldModelcovId,ownerModel,ownerCovPath,allTests);

                if status==0
                    return;
                end


                moveBlockTypes(harnessModelcovId,oldModelcovId);

                cvi.TopModelCov.checkModelConistency(oldModelcovId);


                fixTopModelCovId(harnessModelcovId,oldModelcovId);



                cv('set',currentRootId,'.testobjectives',[]);
                cv('SetTestList',currentRootId,[]);
                cv('set',harnessModelcovId,'.currentTest',[]);
                cv('ModelClose',harnessModelcovId);
                newRootId=oldRootId;
            elseif~strcmpi(cv('Feature','ModelCov Compatibility'),'on')
                return;
            end
        end

        if isempty(newRootId)&&~isempty(oldModelcovId)
            if cvi.TopModelCov.isRootMergePossible(harnessModelcovId,currentRootId)

                allTests=cv('TestsIn',harnessModelcovId);


                status=adjustRoot(currentRootId,harnessModelcovId,ownerModel,ownerCovPath,allTests);

                if status==0
                    return;
                end

                cv('MergeModels',oldModelcovId,harnessModelcovId);


                cv('set',allTests,'.modelcov',oldModelcovId);


                moveBlockTypes(harnessModelcovId,oldModelcovId);


                fixTopModelCovId(harnessModelcovId,oldModelcovId);


                cv('set',harnessModelcovId,'.currentTest',[]);
                cv('SetTestList',harnessModelcovId,[]);

                cv('ModelClose',harnessModelcovId);


                status=cvi.TopModelCov.updateModelHandles(oldModelcovId,ownerModel);

                if status==0
                    return;
                end

                cvi.TopModelCov.checkModelConistency(oldModelcovId);

                newRootId=findRoot(oldModelcovId,ownerCovPath);
            elseif~strcmpi(cv('Feature','ModelCov Compatibility'),'on')
                cv('set',harnessModelcovId,'.canHarnessMapBackToOwner',false);
                return;
            end

        end

        if isempty(newRootId)

            allTests=cv('TestsIn',currentRootId);
            status=adjustRoot(currentRootId,harnessModelcovId,ownerModel,ownerCovPath,allTests);

            if status==0
                return;
            end
            resetHarnessInfo(harnessModelcovId);

            cvi.TopModelCov.deleteInstance(ownerModel);
            cvi.TopModelCov.checkModelConistency(harnessModelcovId);
            newRootId=currentRootId;
        end


        if~isempty(allTests)
            tcvd=cvdata(allTests(end));
            resetFilterApplied(newRootId,tcvd);
        end


        if cvd.id==0
            cvd.setRootId(newRootId);
        end
    catch MEx
        rethrow(MEx);
    end
end

function resetFilterApplied(rootId,cvd)

    roots=cv('RootsIn',cv('get',rootId,'.modelcov'));
    for idx=1:numel(roots)
        cvi.TopModelCov.resetFilter(roots(idx),cvd,false);
    end
    cvi.TopModelCov.setModelCovFilterApplied(cv('get',rootId,'.modelcov'),[]);
end



function res=isCompatibleRoots(oldRootId,newRootId)

    cvi.RootVariant.resetRootVariants(cv('get',oldRootId,'.modelcov'));
    cvi.RootVariant.compareRootVariants(newRootId,oldRootId);
    res=isequal(cv('get',oldRootId,'.checksum'),cv('get',newRootId,'.checksum'));
end

function resetHarnessInfo(modelcovId)
    cv('set',modelcovId,'.ownerModel','');
    cv('set',modelcovId,'.harnessModel','');
    cv('set',modelcovId,'.ownerBlock','');
end


function moveBlockTypes(harnessModelcovId,oldModelcovId)


    harnessBlockTypes=cv('get',harnessModelcovId,'.blockTypes');
    oldModelcovBlockTypes=cv('get',oldModelcovId,'.blockTypes');
    cv('set',oldModelcovId,'.blockTypes',[oldModelcovBlockTypes,harnessBlockTypes]);
    cv('set',harnessModelcovId,'.blockTypes',[]);
end

function addTests(rootId,allTests)
    for idx=1:numel(allTests)
        cv('RootAddTest',rootId,allTests(idx));
    end
end

function currentRootId=pickRoot(allRootIds,ownerBlockPath)
    if numel(allRootIds)==1
        currentRootId=allRootIds;
        return;
    end
    currentRootId=[];
    for idx=1:numel(allRootIds)
        currCovPath=cv('get',allRootIds(idx),'.path');
        scp=split(string(currCovPath),'/');
        sop=split(string(ownerBlockPath),'/');
        if strcmpi(scp{end},sop{end})
            currentRootId=allRootIds(idx);
            return;
        end
    end
end

function ownerCovPath=getOwnerCovPath(currentRootId,ownerModel,ownerBlockPath)
    ownerCovPath=ownerBlockPath((numel(ownerModel)+2):end);
    currCovPath=cv('get',currentRootId,'.path');
    if~strcmpi(ownerCovPath,currCovPath)

        scp=split(string(currCovPath),'/');
        if numel(scp)>1
            scp{1}=ownerCovPath;
            ownerCovPath=char(join(scp,'/'));
        end
    end
end

function status=adjustRoot(rootId,currModelcovId,ownerModel,covPath,allTests)
    cv('SetRootPath',rootId,covPath);
    topSlsf=cv('get',rootId,'.topSlsf');
    fullCovPath=cvi.TopModelCov.checkCovPath(ownerModel,covPath);
    cv('SetSlsfName',topSlsf,get_param(fullCovPath,'name'));
    rootSlHandle=get_param(fullCovPath,'handle');
    cv('set',rootId,'.topSlHandle',rootSlHandle);
    cv('set',currModelcovId,'.activeRoot',rootId);
    status=cvi.TopModelCov.updateModelHandles(currModelcovId,ownerModel);
    if status==0
        return;
    end
    cv('set',rootId,'.modelDepth',cvi.TopModelCov.getBlockDepth(rootSlHandle));
    cv('set',allTests,'.modelcov',currModelcovId);
    cv('set',allTests,'.rootPath',covPath);
end

function rootId=findRoot(modelcovId,blockPath)
    rootIds=cv('RootsIn',modelcovId);
    rootId=[];
    for idx=1:numel(rootIds)
        rootPath=cv('GetRootPath',rootIds(idx));

        if(isempty(rootPath)&&isempty(blockPath))||isequal(blockPath,rootPath)
            rootId=rootIds(idx);
            return;
        end
    end
end

function fixTopModelCovId(removedTopCovId,newTopCovId)
    allModelCov=cv('find','all','.isa',cv('get','default','modelcov.isa'));
    codecovModelcov=cv('find',allModelCov,'.topModelcovId',removedTopCovId);
    codecovModelcov=codecovModelcov(codecovModelcov~=removedTopCovId);
    cv('set',codecovModelcov,'.topModelcovId',newTopCovId);
end
