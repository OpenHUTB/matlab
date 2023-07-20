function DSMaskCloseCallback(this,~)




    dialogSource=this.getDialogSource();
    blkHndl=get_param(getFullName(dialogSource.getBlock),'Handle');


    dialogSource.signals=regexp(get_param(blkHndl,'Signals'),'#','split')';
    dialogSource.selection=get_param(blkHndl,'SelectedSignal');

    dialogSource.closeCallback(this);

end
