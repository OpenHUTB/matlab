

function outRange=unionRange(varargin)

    u=[];
    for varIdx=1:nargin
        u=SimulinkFixedPoint.safeConcat(u,varargin{varIdx});
    end
    outRange=[min(u),max(u)];
end