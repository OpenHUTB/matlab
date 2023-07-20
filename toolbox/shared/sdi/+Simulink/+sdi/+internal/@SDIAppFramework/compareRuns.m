function ret=compareRuns(~,varargin)
    if isempty(varargin)
        ret=Simulink.sdi.DiffRunResult.empty();
    else
        ret=Simulink.sdi.compareRuns(varargin{:});
    end
end
