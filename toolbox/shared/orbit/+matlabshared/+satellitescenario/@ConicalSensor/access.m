function ac=access(sensor,varargin)%#codegen
























































































































    coder.allowpcode('plain');

    if nargin>1
        ac=matlabshared.satellitescenario.internal.AddAssetsAndAnalyses.access(sensor,varargin{:});
    else
        ac=matlabshared.satellitescenario.internal.AddAssetsAndAnalyses.access(sensor);
    end
end

