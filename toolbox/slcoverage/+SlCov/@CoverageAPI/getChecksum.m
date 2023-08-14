function chks=getChecksum(modelCovPath)
    try
        chks=[];
        modelH=getHandle(modelCovPath);
        if isempty(modelH)
            return;
        end
        modelName=get_param(modelH,'name');
        modelcovId=get_param(modelH,'CoverageId');
        if modelcovId==0
            return;
        end
        rootIds=cv('RootsIn',modelcovId);
        if isempty(rootIds)
            return;
        end
        rootId=[];
        if~isequal(modelCovPath,modelName)
            covPath=modelCovPath(numel(modelName)+2:end);
            for idx=1:numel(rootIds)
                if isequal(covPath,cv('get',rootIds(idx),'.path'))
                    rootId=rootIds(idx);
                    break;
                end
            end
        else

            rootId=rootIds(1);
        end

        if~isempty(rootId)&&rootId~=0
            chks=cv('get',rootId,'.checksum');
        end
    catch MEx
        rethrow(MEx);
    end

    function blkH=getHandle(blkH)

        if isempty(blkH)
            return;
        end

        blkH=get_param(blkH,'handle');
        if blkH==0||~ishandle(blkH)
            blkH=[];
            return;
        end
        blkH=bdroot(blkH);
