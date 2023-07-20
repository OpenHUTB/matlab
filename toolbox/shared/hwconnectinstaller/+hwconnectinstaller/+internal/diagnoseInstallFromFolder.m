function info=diagnoseInstallFromFolder(folder)


























    validateattributes(folder,{'char'},{'nonempty'},'diagnoseInstallFromFolder','folder');

    mlRelease=hwconnectinstaller.util.getCurrentRelease();
    mlRelTag=hwconnectinstaller.SupportPackage.getReleaseTag(mlRelease);
    pattern='(?<pkgTag>[a-zA-Z0-9]+)_(?<relTag>[a-zA-Z0-9]+)_(?<verTag>\w+)\.zip';

    info.status='FolderDoesNotExist';
    info.matchingZipNames={};

    if~isdir(folder)
        return;
    end

    allZips=dir(fullfile(folder,'*.zip'));
    matchInfo=regexp({allZips.name},pattern,'names');

    for i=1:numel(allZips)
        if isempty(matchInfo{i})
            allZips(i).IsSupportPkgTemplate=false;
            allZips(i).IsSupportPkgMatchedRelease=false;
        else
            allZips(i).IsSupportPkgTemplate=true;
            allZips(i).IsSupportPkgMatchedRelease=strcmpi(matchInfo{i}.relTag,mlRelTag);
        end
    end

    noMatchingZipNames=isempty(allZips)||~any([allZips.IsSupportPkgTemplate]);
    if noMatchingZipNames
        info.status='NoPkgsFound';
        return;
    end

    matchingReleaseIndices=find([allZips.IsSupportPkgMatchedRelease]);

    noMatchingReleaseNames=isempty(matchingReleaseIndices);
    if noMatchingReleaseNames

        info.status='PkgsFoundForDifferentRelease';
        return;
    end

    info.status='PkgsFoundForCurrentRelease';
    info.matchingZipNames=cell(numel(matchingReleaseIndices),1);
    for i=1:numel(matchingReleaseIndices)
        idx=matchingReleaseIndices(i);
        info.matchingZipNames{i}=fullfile(folder,allZips(idx).name);
    end
    assert(numel(info.matchingZipNames)>0);

end
