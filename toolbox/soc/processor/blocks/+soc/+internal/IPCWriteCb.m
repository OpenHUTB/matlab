function varargout=IPCWriteCb(func,blkH,varargin)




    if nargout==0
        feval(func,blkH,varargin{:});
    else
        [varargout{1:nargout}]=feval(func,blkH,varargin{:});
    end
end


function MaskInitFcn(blkH)%#ok<*DEFNU>
    persistent hadError
    if isempty(hadError)
        hadError=false;
    end
    locSetMaskHelp(blkH);
    try


        if isequal(get_param(bdroot(blkH),'SimulationStatus'),'stopped')||...
            isequal(get_param(bdroot(blkH),'SimulationStatus'),'updating')
        end

        soc.internal.setBlockIcon(blkH,'socicons.IPCWrite');
    catch ME
        hadError=true;
        rethrow(ME);
    end
end


function locSetMaskHelp(blkH)
    helpcmd='eval(''soc.internal.helpview(''''soc_ipcwrite'''')'')';
    set_param(blkH,'MaskHelp',helpcmd);
end


