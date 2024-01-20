function setCursorPositions(varargin)

    p=inputParser;
    p.addParameter('Left',NaN,@(x)validateattributes(x,"numeric",{'finite','scalar','real'}));
    p.addParameter('Right',NaN,@(x)validateattributes(x,"numeric",{'finite','scalar','real'}));
    p.addParameter('View','inspect',@(x)validateattributes(x,{'char','string'},{}));

    try
        p.parse(varargin{:});
        res=p.Results;
        if isstring(res.View)
            validateattributes(res.View,"string",{'scalar'},'setCursorPositions','View')
        end
        Simulink.sdi.setCursorPositionsImpl(res.Left,res.Right,res.View);
    catch me
        me.throwAsCaller();
    end
end
