function[comparisonRunID]=compareRunsWithTolerance(sigRepository,runID1,runID2,varargin)
    [alignment,selectedSig,tolerance,options]=locGetOptions(varargin{:});
    comparisonRunID=Simulink.sdi.compareRunsWithToleranceInternal(...
    sigRepository,...
    runID1,runID2,...
    Simulink.sdi.Instance.isTestOrSDIRunning(),...
    alignment,selectedSig,tolerance,options);
end


function[alignment,selectedSig,tolerance,options]=locGetOptions(varargin)
    alignment=[];
    selectedSig=[];
    tolerance=[];
    options=[];

    if isempty(varargin)
        return
    end

    if nargin>0
        alignment=varargin{1};
    end

    if nargin>1
        selectedSig=varargin{2};
    end

    if nargin>2
        tolerance=varargin{3};
    end

    if nargin>3
        options=varargin{4};
    end
end

