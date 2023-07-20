function b=isInternal

    b=exist(fullfile(matlabroot,'REMOVE_BEFORE_FLIGHT'),'file')==2;