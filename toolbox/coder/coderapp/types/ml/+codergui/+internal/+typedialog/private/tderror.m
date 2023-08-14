function tderror(msgArg,varargin)




    if ischar(msgArg)
        msgArg=[['coderApp:typeDialog:',msgArg],varargin];
    else
        narginchk(1,1);
    end
    codergui.internal.util.customError(msgArg,'Namespace','CoderTypeDialog','StackOffset',2);
end
