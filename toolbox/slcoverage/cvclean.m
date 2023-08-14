function cvclean(varargin)











    [varargin{:}]=convertStringsToChars(varargin{:});
    if isempty(varargin)
        modelNames{1}='ALL';
        ignoreModelLoaded=false;
    else
        if islogical(varargin{end})
            ignoreModelLoaded=varargin{end};
            modelNames=varargin(1:end-1);
        else
            modelNames=varargin;
            ignoreModelLoaded=false;
        end
    end
    if strcmpi(modelNames{1},'ALL')
        modelcov_ids=cv('get','all','modelcov.id');
        for this_id=modelcov_ids(:)'
            cleanIt(this_id,ignoreModelLoaded);
        end


        cv.coder.cvdatamgr.instance().removeAll();
    else
        for modelName=modelNames'
            modelcov_id=SlCov.CoverageAPI.findModelcov(modelName{1});
            if~isempty(modelcov_id)
                if~cleanHarnesses(modelcov_id,ignoreModelLoaded)||~cleanIt(modelcov_id,ignoreModelLoaded)
                    warning(message('Slvnv:simcoverage:cvclean:ModelOpen',modelName{1},modelName{1}));
                end
            end


            cv.coder.cvdatamgr.instance().removeAll(modelName{1});
        end
    end
end

function res=cleanHarnesses(modelcov_id,ignoreModelLoaded)
    harnessModel=cv('get',modelcov_id,'.harnessModel');
    res=true;
    if~isempty(harnessModel)
        harness_id=SlCov.CoverageAPI.findModelcov(harnessModel);
        if~isempty(harness_id)
            res=cleanIt(harness_id,ignoreModelLoaded);
        end
    end
end

function res=cleanIt(modelcov_id,ignoreModelLoaded)
    if~cv('ishandle',modelcov_id)
        res=true;
        return;
    end
    res=false;
    if SlCov.CoverageAPI.isGeneratedCode(modelcov_id)

        if cv('get',modelcov_id,'.isScript')==1
            if isempty(find_system('SearchDepth',0))
                cv('ClearModel',modelcov_id);
                res=true;
            end
            return
        end
    end
    modelname=SlCov.CoverageAPI.getModelcovName(modelcov_id);

    if ignoreModelLoaded||isempty(find_system('SearchDepth',0,'name',modelname))
        cv('ClearModel',modelcov_id);
        res=true;
    end
end









