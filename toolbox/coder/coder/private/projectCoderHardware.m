function varargout=projectCoderHardware(varargin)








    coderTarget=coder.internal.CoderGuiDataManager.getCoderTargetDisabled();

    if~coderTarget&&~isempty(which('coder.hardware'))

        binding=@coder.hardware;
    else
        binding=[];
    end

    if~isempty(binding)
        if nargout>0
            [varargout{1:nargout}]=binding(varargin{:});
        else
            binding(varargin{:});
        end
    else
        [varargout{1:nargout}]=deal({});
    end
end