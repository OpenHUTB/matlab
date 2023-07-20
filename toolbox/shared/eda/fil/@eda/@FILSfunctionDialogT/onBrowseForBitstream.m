function onBrowseForBitstream(this,dialogH)

    switch(this.BuildInfo.BoardObj.Component.PartInfo.FPGAVendor)
    case 'Altera'
        filterspec={...
        '*.sof',[getString(message('EDALink:FILWizard:AlteraBitstreamFiles_Dialog')),' (*.sof)'];...
        '*.*',[getString(message('EDALink:FILWizard:AllFiles_Dialog')),' (*.*)']};
    case 'Xilinx'
        filterspec={...
        '*.bit',[getString(message('EDALink:FILWizard:XilinxBitstreamFiles_Dialog')),' (*.bit)'];...
        '*.*',[getString(message('EDALink:FILWizard:AllFiles_Dialog')),' (*.*)']};
    otherwise
        filterspec={...
        '*.*',[getString(message('EDALink:FILWizard:AllFiles_Dialog')),' (*.*)']};
    end

    [filename,pathname,index]=uigetfile(...
    filterspec,...
    getString(message('EDALink:FILWizard:BrowseBitstreamFileTitle_Dialog')),...
    this.dialogState.prevBrowsePath);

    if(index~=0)
        this.dialogState.prevBrowsePath=pathname;
        dialogH.setWidgetValue('bitFileEdit',fullfile(pathname,filename));
    end

end
