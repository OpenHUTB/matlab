function canlib_loading(libName)
%CANLIB_LOADING Wanrs users of obsolete simulink blocks in target library.
%
%   CANLIB_LOADING(LIBNAME) warns the users of obsolete simulink blocks in
%   target library, LIBNAME.
%
%   This function is called in the PostLoadFcn callback for canblocks.mdl
%   and vector_candrivers.mdl library.

%   Copyright 2008-2012 The MathWorks, Inc.

% Allow MathWorks legacy test models to not issue this warning.
if strcmp(getenv('DisableObsoleteCANBlocksWarnings'),'1')
    return;
end
    
% Store the warning status
prevWarningStatus = warning('off', 'backtrace');
% Warn depending on the library. 
switch libName
    case 'messageblocks'
        warning(message('TargetCommon:can:messageblocks'));
    case 'vectorblocks'
        warning(message('TargetCommon:can:vectorblocks'));                
end

% Restore the warning status
warning(prevWarningStatus);

%endfunction