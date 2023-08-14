function blocks=findBlocksOfType(sys,varargin)










































    try
        sysHandle=get_param(sys,'handle');
        if iscell(sysHandle)
            sysHandle=cell2mat(sysHandle);
        end
    catch causeException
        throw(addCause(MException(...
        message('Simulink:Commands:FindBlocksMustHaveSystemArg')),...
        causeException));
    end

    blocks=Simulink.internal.findBlocksOfType(sysHandle,varargin{:});
end