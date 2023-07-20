function pterror(msgArg,varargin)

    if ischar(msgArg)
        msgArg=[['coderApp:config:',msgArg],varargin];
    else
        narginchk(1,1);
    end
    codergui.internal.util.customError(msgArg,'Namespace','CoderAppConfig','StackOffset',2);
end