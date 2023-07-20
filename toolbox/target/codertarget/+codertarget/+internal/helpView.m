function helpView(sppkgLabelStr,blockId,varargin)




    validateattributes(sppkgLabelStr,{'char'},{'nonempty'},'helpView','blkPlatform');
    validateattributes(blockId,{'char'},{'nonempty'},'helpView','blockId');

    sppkgTag=codertarget.internal.convertStringToTag(sppkgLabelStr);
    assert(isequal(exist(['codertarget.internal.',sppkgTag],'class'),8),['Undefined class codertarget.internal.',sppkgTag]);

    sppkgMethods=methods(['codertarget.internal.',sppkgTag]);
    assert(any(strcmp(sppkgMethods,'getDocRoot')),...
    ['getDocRoot method not defined for class codertarget.internal.',sppkgTag]);
    docRoot=feval(['codertarget.internal.',sppkgTag,'.getDocRoot']);
    helpview(fullfile(docRoot,'helptargets.map'),blockId);