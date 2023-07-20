function this=verifySignalAndModelPaths(this,action)
























    if nargin<2
        action='error';
    end


    if~strcmp('error',action)&&...
        ~strcmp('remove',action)&&...
        ~strcmp('warnAndRemove',action)
        DAStudio.error(...
        'Simulink:Logging:MdlLogInfoIncorrectVerifyArg');
    end


    try
        this=this.validate(...
        this.model_,...
        true,...
        true,...
        false,...
        action);
    catch me
        throwAsCaller(me);
    end
end
