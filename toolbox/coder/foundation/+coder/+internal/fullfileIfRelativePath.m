function lPathsReAnchored=fullfileIfRelativePath(lPaths,pathPrepend)





    isCellInput=iscell(lPaths);
    if~isCellInput
        lPaths={lPaths};
    end

    lPathsReAnchored=cell(size(lPaths));

    lIsRelativePath=coder.make.internal.isRelativePath(lPaths);

    lIsEmpty=cellfun(@isempty,lPaths);

    reAnchorIdx=lIsRelativePath&~lIsEmpty;

    lPathsReAnchored(~reAnchorIdx)=lPaths(~reAnchorIdx);
    lPathsReAnchored(reAnchorIdx)=fullfile(pathPrepend,lPaths(reAnchorIdx));



    lPathsReAnchored=RTW.reduceRelativePath(lPathsReAnchored);

    if~isCellInput
        lPathsReAnchored=lPathsReAnchored{1};
    end
