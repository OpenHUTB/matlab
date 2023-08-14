function dStruct=getDialogSchema(this,~)

    title='Loading FPGA bitstream';
    dStruct.DialogTitle=title;
    dStruct.DialogTag='FILLoadBitStreamDialogT';
    dStruct.StandaloneButtonSet={'OK'};
    dStruct.Sticky=true;




    topC.Type='panel';
    topC.Tag='topC';
    topC.LayoutGrid=[2,1];
    topC.RowStretch=[0,1];
    topC.RowSpan=[1,1];
    topC.ColSpan=[1,1];


    infoC.Type='panel';
    infoC.Tag='infoC';
    infoC.RowSpan=[1,1];
    infoC.ColSpan=[1,1];
    infoC.Items={l_CreateInfoText(this)};


    statusC.Type='panel';
    statusC.Tag='statusC';
    statusC.RowSpan=[2,2];
    statusC.ColSpan=[1,1];
    statusC.Items={l_CreateStatus(this)};

    topC.Items={infoC,statusC};

    dStruct.Items={topC};


end


function infoText=l_CreateInfoText(this)
    formatStr='%25s: %s\n';
    infoText.Type='text';
    infoText.Name=...
    [sprintf(formatStr,'Bitstream file name',this.FileName),...
    sprintf(formatStr,'Board name',this.BoardName),...
    sprintf(formatStr,'Device name',this.DeviceName)];
    infoText.WordWrap=1;
    infoText.FontFamily='courier';
    infoText.Tag='infoText';
    infoText.MinimumSize=[500,0];
end


function statusGroup=l_CreateStatus(this)
    statusGroup.Type='group';
    statusGroup.Tag='statusGroup';
    statusGroup.Name='Status:';
    statusText.Type='textbrowser';
    statusText.Tag='statusText';
    statusText.Text=this.Status;
    statusText.FontFamily='courier';

    statusGroup.Items={statusText};
end
