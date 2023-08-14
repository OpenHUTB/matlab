function[ret,msg]=DSMaskPreRevertCallback(obj,~)




    dialogSource=obj.getDialogSource();
    blkHndl=get_param(getFullName(dialogSource.getBlock),'Handle');


    dialogSource.signals=regexp(get_param(blkHndl,'Signals'),'#','split')';
    dialogSource.selection=get_param(blkHndl,'SelectedSignal');

    ret=true;
    msg=getString(message('sl_sta_ds:staDerivedSignal:DSNoError'));
end

