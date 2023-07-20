function interimSaveLibraryBuildInfos(buildInfo)






    anchorFolder=buildInfo.Settings.LocalAnchorDir;


    linkObjs=buildInfo.LinkObjsDirect;
    if~isempty(linkObjs)
        dirty=[linkObjs.BuildInfoDirty];
        for i=find(dirty)
            buildInfo=linkObjs(i).BuildInfoHandle;
            libFolder=strrep(linkObjs(i).Path,'$(START_DIR)',anchorFolder);


            save(fullfile(libFolder,'buildInfo.mat'),'-v7','buildInfo');
        end
    end



