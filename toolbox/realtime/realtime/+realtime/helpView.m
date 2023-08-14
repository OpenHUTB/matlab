function helpView(sppkgLabelStr,blockId,varargin)




    validateattributes(sppkgLabelStr,{'char'},{'nonempty'},'helpView','blkPlatform');
    validateattributes(blockId,{'char'},{'nonempty'},'helpView','blockId');

    sppkgTag=realtime.convertStringToTag(sppkgLabelStr);
    assert(isequal(exist(['realtime.internal.',sppkgTag],'class'),8),['Undefined class realtime.internal.',sppkgTag]);
    assert(any(ismember(methods(['realtime.internal.',sppkgTag]),'getDocRoot')),...
    ['getDocRoot method not defined for class realtime.internal.',sppkgTag]);
    docRoot=feval(['realtime.internal.',sppkgTag,'.getDocRoot']);
    helpview(fullfile(docRoot,'helptargets.map'),blockId);

