function fixReleaseChecksumCompatibility(modelcovId)




    testIds=cv('TestsIn',modelcovId);
    testIds(testIds==0)=[];
    if isempty(testIds)
        return;
    end
    dbVersion=cv('get',testIds(1),'.dbVersion');
    if str2double(dbVersion(3:end-2))>=2019
        return;
    end
    rootIds=cv('RootsIn',modelcovId);

    if isempty(rootIds)
        return;
    end
    topRootId=rootIds(1);
    topSlsf=cv('get',topRootId,'.topSlsf');
    allIds=cv('DecendentsOf',topSlsf);
    allIds=[topSlsf,allIds];
    stateflowSlslfobjIds=cv('find',allIds,'.origin',2);

    for idxI=1:numel(stateflowSlslfobjIds)
        slsfobjId=stateflowSlslfobjIds(idxI);
        parentCvId=cv('get',slsfobjId,'.treeNode.parent');
        isParentSimulink=cv('get',parentCvId,'.origin')==1;
        if isParentSimulink
            sifgrangeIsa=cv('get','default','sigrange.isa');
            [sigrangeId,isa]=cv('MetricGet',parentCvId,cvi.MetricRegistry.getEnum('sigrange'),'.id','.isa');
            if(sigrangeId~=0&&sifgrangeIsa==isa)
                cv('set',sigrangeId,'.ignoreInChecksum',1);
            end
        end
    end
    for idx=1:numel(rootIds)
        cv('RootUpdateChecksum',rootIds(idx));
    end
end
