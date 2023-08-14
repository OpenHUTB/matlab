function rootDir=gpucoder_dl_targets_spkg_crumb






    currentFilePath=mfilename('fullpath');
    filesubpath=fullfile('gpucoder_dl_targets','+dltargets',...
    'gpucoder_dl_targets_spkg_crumb');

    filesubpath=regexprep(filesubpath,'[(\\|\+)]','\\$0');
    splitres=regexp(currentFilePath,filesubpath,'split');
    assert(~isempty(splitres{1}));
    rootDir=splitres{1};
end
