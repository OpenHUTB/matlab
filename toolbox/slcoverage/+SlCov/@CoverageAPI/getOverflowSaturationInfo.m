



function varargout=getOverflowSaturationInfo(covdata,block,ignoreDescendants)

    if nargin<3||isempty(ignoreDescendants)
        ignoreDescendants=0;
    end

    if nargout>1
        [cov,desc]=SlCov.CoverageAPI.getCoverageInfo(covdata,block,cvmetric.Structural.saturate,ignoreDescendants);
        varargout{1}=cov;
        if~isempty(desc)
            if isfield(desc,'testobjects')
                desc.decision=desc.testobjects;
                desc=rmfield(desc,'testobjects');
            end
        end
        varargout{2}=desc;
    else
        varargout{1}=SlCov.CoverageAPI.getCoverageInfo(covdata,block,cvmetric.Structural.saturate,ignoreDescendants);
    end
