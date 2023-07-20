function cvresolve(model)













    [status,msgId]=SlCov.CoverageAPI.checkCvLicense;
    if status==0
        error(message(msgId));
    end

model_name_refresh

    if nargin
        model=convertStringsToChars(model);
    end

    if(nargin>=1)&&~isempty(model)
        if~ischar(model)
            error(message('Slvnv:simcoverage:cvresolve:InvalidModelNameNotString'));
        end
        try
            bdHandle=get_param(model,'Handle');%#ok<NASGU>
        catch
            error(message('Slvnv:simcoverage:cvresolve:UnableToFindModel'));
        end

        modelNameMangled=SlCov.CoverageAPI.mangleModelcovName(model);
        modelId=SlCov.CoverageAPI.findModelcovMangled(modelNameMangled);
        switch length(modelId)
        case 0
            warning(message('Slvnv:simcoverage:cvresolve:ModelNotExist'));
            return;
        case 1
            resolve_this_model(modelId);
            return;
        otherwise
            error(message('Slvnv:simcoverage:cvresolve:InvalidModelName'));
        end
    end

    cvModels=cv('get','all','modelcov.id');

    for ii=1:numel(cvModels)
        modelId=cvModels(ii);
        try
            model=SlCov.CoverageAPI.getModelcovName(modelId);
            bdHandle=get_param(model,'Handle');%#ok<NASGU>
        catch
            continue
        end
        resolve_this_model(modelId);
    end


    function resolve_this_model(modelId)

        cv('ResolveSlLinks',modelId);
