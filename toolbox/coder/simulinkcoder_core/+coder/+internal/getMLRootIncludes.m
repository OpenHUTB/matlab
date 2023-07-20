function[incPaths,incGroups,srcPaths,srcGroups]=getMLRootIncludes





    standardGroup='Standard';


    incPaths={fullfile(matlabroot,'extern','include'),...
    fullfile(matlabroot,'simulink','include'),...
    fullfile(matlabroot,'rtw','c','src'),...
    };

    incGroups={standardGroup,standardGroup,standardGroup};

    srcPaths={fullfile(matlabroot,'rtw','c','src'),...
    fullfile(matlabroot,'simulink','src')};
    srcGroups={standardGroup,standardGroup};
end
