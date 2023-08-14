
function rootId=getRootId(blkH,sfId)
    rootId=[];
    if isempty(blkH)
        if~isempty(sfId)
            if sf('get','default','script.isa')==sf('get',sfId,'.isa')
                modelcovIds=cv('find','all','.isa',cv('get','default','modelcov.isa'));
                scriptModelcovIds=cv('find',modelcovIds,'.isScript',1);
                rootIds=cv('get',scriptModelcovIds,'.rootTree.child');
                scriptCvIds=cv('get',cv('get',rootIds,'.topSlsf'),'.treeNode.child');
                scriptHandles=cv('get',scriptCvIds,'.handle');
                rootId=rootIds(scriptHandles==sfId);
                assert(numel(rootId)==1);
            else
                charId=sfprivate('getChartOf',sfId);
                blkH=sfprivate('chart2block',charId);
            end
        end
    end
    if~isempty(blkH)
        modelcovId=get_param(bdroot(blkH),'CoverageId');
        rootId=cv('get',modelcovId,'.rootTree.child');
        if rootId==0
            rootId=[];
        end
    end
