



function varargout=getExecutionInfo(covdata,block,varargin)

    if nargin<2&&nargin>0

        [~,hasMLCoderCov]=SlCov.CoverageAPI.hasSLOrMLCoderCovData(covdata);
        if hasMLCoderCov
            block='';
        end
    end

    if nargout>1
        [cov,desc]=SlCov.CoverageAPI.getCoverageInfo(covdata,block,cvmetric.Structural.block,varargin{:});
        varargout{1}=cov;
        if~isempty(desc)
            if isfield(desc,'testobjects')
                desc.decision=desc.testobjects;

                if~isfield(desc.decision,'executionCount')
                    for ii=1:numel(desc.decision)
                        desc.decision(ii).executionCount=desc.decision(ii).outcome.executionCount;
                    end
                    desc.decision=rmfield(desc.decision,'outcome');
                end
                desc=rmfield(desc,'testobjects');
            end
        end
        varargout{2}=desc;
    else
        varargout{1}=SlCov.CoverageAPI.getCoverageInfo(covdata,block,cvmetric.Structural.block,varargin{:});
    end


