function cvmodelclean(varargin)











    if isempty(varargin)||strcmpi(varargin{1},'ALL')
        modelcov_ids=cv('get','all','modelcov.id');
        for this_id=modelcov_ids(:)'
            modelName=SlCov.CoverageAPI.getModelcovName(this_id);
            closeResultsExplorer(modelName);
            cvi.Informer.close(this_id);
        end
    else
        for this_arg=varargin'
            modelName=get_param(this_arg{1},'Name');
            closeResultsExplorer(modelName);
            modelcovId=SlCov.CoverageAPI.findModelcov(modelName);
            badIdx=[];
            for ii=1:numel(modelcovId)
                if SlCov.CoverageAPI.isGeneratedCode(modelcovId(ii))
                    badIdx=[badIdx,ii];%#ok<AGROW>
                end
            end
            modelcovId(badIdx)=[];
            if isempty(modelcovId)
                return
            end
            topModelCovId=cv('get',modelcovId,'.topModelcovId');
            if topModelCovId==0




                cvi.Informer.close(modelcovId);
            elseif any(modelcovId==topModelCovId)
                cvi.Informer.close(topModelCovId);
            end
        end
    end

    function closeResultsExplorer(modelH)
        if SlCov.CoverageAPI.feature('results')
            cvi.ResultsExplorer.ResultsExplorer.close(modelH);
        end








