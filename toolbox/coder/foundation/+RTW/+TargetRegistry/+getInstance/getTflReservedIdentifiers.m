function reservedIds=getTflReservedIdentifiers(varargin)





    tr=RTW.TargetRegistry.getInstance;
    reservedIds=coder.internal.getTflReservedIdentifiers(tr,varargin{:});

