




function handle=getRootHandle(rootId)

    try
        rp=cv('GetRootPath',rootId);

        bn=SlCov.CoverageAPI.getModelcovName(cv('get',rootId,'.modelcov'));
        if~isempty(rp)

            bn=[bn,'/',rp];
        end
        handle=get_param(bn,'handle');
    catch MEx

        handle=0;
    end
