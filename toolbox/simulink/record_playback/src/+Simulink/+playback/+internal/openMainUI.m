
function openType=openMainUI(config)
    blkHandle=getSimulinkBlockHandle(config.BlockPath);
    url=Simulink.playback.mainApp.getURL(config);

    if GLUE2.StudioApp.isInInteractiveOpen

        studioApp=GLUE2.StudioApp.getStudioAppForInteractiveOpen();
        openType=studioApp.getEditorOpenType();
    else

        openType=config.OpenType;

        studioApp=SLM3I.SLDomain.getLastActiveStudioAppFor(bdroot(blkHandle));
    end


    if(strcmp(get_param(bdroot(blkHandle),'Lock'),'on'))
        errordlg(getString(message('record_playback:errors:PlaybackOpenUIInLockedSystem')));
        return
    end

    if~isempty(studioApp)



        d=SA_M3I.StudioAdapterDomain.getCreateStudioAdapterDiagramForBlockHandle(blkHandle);
        matchingEditor=locGetMatchingEditor(d);
        if~isempty(matchingEditor)



            errorID='record_playback:errors:MultiViewErrorPlayback';
            fullMessage=DAStudio.message(errorID,config.BlockPath);
            editor=studioApp.getActiveEditor;
            editor.deliverInfoNotification(errorID,fullMessage);
            return;
        end
    end

    if slsvTestingHook('DisablePlaybackEditorOpen')
        if isempty(studioApp)
            open_system(bdroot(blkHandle));
            studioApp=SLM3I.SLDomain.getLastActiveStudioAppFor(bdroot(blkHandle));
        end
        d=SA_M3I.StudioAdapterDomain.getCreateStudioAdapterDiagramForBlockHandle(blkHandle);
        editor=studioApp.openEditor(d);
    else
        editor=SLStudio.StudioAdapter.StudioAdapterOpenFcn(blkHandle,url,openType);
    end

    editor.DestroyOnHide=true;
end


function editor=locGetMatchingEditor(d)
    editorHID=GLUE2.HierarchyServiceUtils.getDefaultHID(d);
    if GLUE2.StudioApp.isInInteractiveOpen
        editorHID=GLUE2.StudioApp.getHIDOfObjectBeingOpenedInteractively;
        if GLUE2.HierarchyService.isValid(editorHID)
            if GLUE2.HierarchyService.isElement(editorHID)
                editorHID=GLUE2.HierarchyServiceUtils.getDiagramHIDWithParent(d,editorHID);
            end
        end
    end

    editor=GLUE2.Editor.findEditorsWithHid(editorHID);
end
