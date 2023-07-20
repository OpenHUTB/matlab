function close(arg)







    if nargin<1
        arg='all';
    end

    if((isStringScalar(arg)||ischar(arg))&&strcmp(arg,'all'))
        internal.sysarch.SystemArchitectureEditor.closeAll;
    elseif isa(arg,'internal.sysarch.SystemArchitectureEditor')
        arg.close;
    else
        error('Unknown input argument');
    end

