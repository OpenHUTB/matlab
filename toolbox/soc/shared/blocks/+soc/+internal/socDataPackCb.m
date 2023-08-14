function varargout=socDataPackCb(func,blkH,varargin)



    if nargout==0
        feval(func,blkH,varargin{:});
    else
        [varargout{1:nargout}]=feval(func,blkH,varargin{:});
    end
end

function MaskInitFcn(~)%#ok<DEFNU>
    soc.internal.registerSoCData;
end

function InitFcn(~)%#ok<DEFNU>
    soc.internal.registerSoCData;
end

