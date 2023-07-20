
function mobileGetChangedFiguresAsync(varargin)
    message.publish('/mobile/changedfigures',mls.internal.figure.mobileGetChangedFigures(varargin{:}))
end

