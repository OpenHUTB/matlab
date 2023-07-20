function tmerror(msgArg,varargin)




    if ischar(msgArg)
        msgArg=[['coderApp:typeMaker:',msgArg],varargin];
    else
        narginchk(1,1);
    end
    codergui.internal.util.customError(msgArg,'Namespace','CoderTypeMaker','StackOffset',2);
end
