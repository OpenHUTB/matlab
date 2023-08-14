function moveRunsToStableArea(varargin)
    runs=int32(0);
    for i=1:nargin
        runs(i)=int32(varargin{i});
    end
    Simulink.sdi.Instance.engine.moveRunsSWS("stable",runs);
end