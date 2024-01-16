function pathEntries=ensurePlatformAppropriatePath(pathEntries)
    assert(iscellstr(pathEntries),'ensurePlatformAppropriatePath: Expected "pathEntries" to be a cell array of strings');
    pathEntries=fullfile(pathEntries);
end