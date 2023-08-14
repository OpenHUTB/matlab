function closeDialogForCtxBlk(blkH)

    if strcmp(get_param(blkH,'BlockType'),'ObserverReference')
        feval('Simulink.observer.dialog.ObsPortDialog.closeDialogForObsBlk',blkH);
    elseif strcmp(get_param(blkH,'BlockType'),'InjectorReference')

    end

end

