function updateProgress(showUI,varargin)
    try
        if showUI
            slreq.utils.updateWaitBar(varargin{:});
        else
            slreq.utils.updateTextBar(varargin{:});
        end
    catch
    end
end