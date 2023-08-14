function runUIFindClones(componentPath,isFollowModelRef,isFollowLibraryLinks)








    if nargin<2
        isFollowModelRef=true;
    end

    if nargin<3
        isFollowLibraryLinks=true;
    end
    model=bdroot(componentPath);
    s=simulinkcoder.internal.util.getSource(model);

    if~isempty(s)&&~isempty(s.studio)






        cloneSettings=Simulink.CloneDetection.Settings();
        cloneSettings.ExcludeModelReferences=~isFollowModelRef;
        cloneSettings.ExcludeLibraryLinks=~isFollowLibraryLinks;

        [~]=Simulink.CloneDetection.findClones(componentPath,cloneSettings);




        oldState=pause('on');
        pause(10);
        pause(oldState);


        clone_detection_app.internal.launchCloneDetectorAppAndOpenResults(model);
    end

end

