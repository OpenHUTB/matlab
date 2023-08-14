function dStruct=getDialogSchema(this,~)








    title=this.block.Name;
    title(double(title)==10)=' ';
    dStruct.DialogTitle=['Block Parameters: ',title,' (FIL)'];
    dStruct.DialogTag=this.block.Name;
    dStruct.PreApplyMethod='preApplyMethod';
    dStruct.PreApplyArgs={'%dialog'};
    dStruct.PreApplyArgsDT={'handle'};
    dStruct.CloseMethod='closeCallback';
    dStruct.CloseMethodArgs={'%dialog'};
    dStruct.CloseMethodArgsDT={'handle'};
    dStruct.HelpMethod='eval';
    dStruct.HelpArgs={this.block.MaskHelp};




    topC.Type='panel';
    topC.Tag='topC';
    topC.LayoutGrid=[2,1];
    topC.RowStretch=[0,1];
    topC.RowSpan=[1,1];
    topC.ColSpan=[1,1];





    descC.Type='group';
    descC.Name=this.block.MaskType;
    descC.Tag='descC';
    descC.RowSpan=[1,1];
    descC.ColSpan=[1,1];
    descC.Items={l_CreateBlockDescriptionWidget(this)};


    tabC.Type='tab';
    tabC.Tag='tabC';
    tabC.RowSpan=[2,2];
    tabC.ColSpan=[1,1];


    mainTab.Name='Main';
    mainTabItemsC.Type='panel';
    mainTabItemsC.Tag='mainTabItemsC';
    mainTabItemsC.LayoutGrid=[3,1];
    mainTabItemsC.Items={l_CreateHardwareInfoWidget(this)};
    mainTabItemsC.Items(2)={l_CreateLoadBitstreamWidget(this)};
    mainTabItemsC.Items(3)={l_CreateRuntimeOptionsWidget(this)};
    mainTabItemsC.Items{1}.RowSpan=[1,1];
    mainTabItemsC.Items{2}.RowSpan=[2,2];
    mainTabItemsC.Items{3}.RowSpan=[3,3];
    mainTab.Items={mainTabItemsC};


    sigTab.Name='Signal Attributes';
    sigTabItemsC.Type='panel';
    sigTabItemsC.Tag='sigTabItemsC';
    sigTabItemsC.LayoutGrid=[1,1];
    sigTabItemsC.Items={l_CreatePortTableWidget(this)};
    sigTab.Items={sigTabItemsC};




    tabC.Tabs={mainTab,sigTab};

    topC.Items={descC,tabC};

    dStruct.Items={topC};


end


function bdItem=l_CreateBlockDescriptionWidget(this)
    bdItem.Type='text';
    bdItem.Name=this.block.MaskDescription;
    bdItem.Tag='BlockDescription';
    bdItem.WordWrap=1;
end


function w=l_AddWidgetChangeCallback(w)
    w.ObjectMethod='onWidgetChange';
    w.MethodArgs={'%dialog','%tag','%value'};
    w.ArgDataTypes={'handle','string','mxArray'};
end


function hwGroup=l_CreateHardwareInfoWidget(this)
    hwGroup.Type='group';
    hwGroup.Name='Hardware Information';
    hwGroup.Tag='hwGroup';
    hwGroup.LayoutGrid=[2,1];

    formatStr='%25s: %s\n';

    macInfo.Type='text';
    macInfo.Tag='macInfo';

    if isempty(this.params.connectionOptions)
        dispName='UDP';
    elseif strcmpi(this.params.connectionOptions.Communication_Channel,'PSEthernet')
        dispName='TCPIP';
    else
        dispName=this.params.connectionOptions.Name;
    end

    macInfo.Name=sprintf(formatStr,'Connection',dispName);
    if strcmpi(dispName,'UDP')||strcmpi(dispName,'Ethernet')
        macInfo.Name=[macInfo.Name,...
        sprintf(formatStr,'MAC address',this.buildInfo.MACAddress),...
        sprintf(formatStr,'IP address',this.buildInfo.IPAddress)];
    end

    macInfo.WordWrap=0;
    macInfo.FontFamily='courier';
    macInfo.RowSpan=[1,1];
    macInfo.ColSpan=[1,1];

    projFile=this.buildInfo.FPGAProjectFile;
    projFile=regexprep(projFile,'^[\.]*[\/\\]','');
    if(length(projFile)>60)
        dispName=['...',projFile(end-56:end)];
        bitInfo.ToolTip=projFile;
    else
        dispName=projFile;
    end
    bitInfo.Type='text';
    bitInfo.Tag='bitInfo';
    bitInfo.Name=...
    [sprintf(formatStr,'Board',this.buildInfo.Board),...
    sprintf(formatStr,'FPGA part',this.buildInfo.FPGAPartInfo),...
    sprintf(formatStr,'FPGA project file',dispName)];
    bitInfo.WordWrap=0;
    bitInfo.FontFamily='courier';
    bitInfo.RowSpan=[2,2];
    bitInfo.ColSpan=[1,1];

    hwGroup.Items={macInfo,bitInfo};

end


function lbGroup=l_CreateLoadBitstreamWidget(this)
    lbGroup.Type='group';
    lbGroup.Tag='lbGroup';
    lbGroup.Name='FPGA Programming File';

    lbGroup.LayoutGrid=[2,3];

    bitFileEdit.Type='edit';
    bitFileEdit.Tag='bitFileEdit';
    bitFileEdit.Name='File name:';
    bitFileEdit.Value=this.dialogState.bitstreamFile;
    bitFileEdit.RowSpan=[1,1];
    bitFileEdit.ColSpan=[1,1];
    bitFileEdit=l_AddWidgetChangeCallback(bitFileEdit);

    bitFileBrowse.Type='pushbutton';
    bitFileBrowse.Name='Browse...';
    bitFileBrowse.ObjectMethod='onBrowseForBitstream';
    bitFileBrowse.MethodArgs={'%dialog'};
    bitFileBrowse.ArgDataTypes={'handle'};
    bitFileBrowse.Alignment=6;
    bitFileBrowse.RowSpan=[1,1];
    bitFileBrowse.ColSpan=[2,2];

    loadBits.Type='pushbutton';
    loadBits.Tag='loadBits';
    loadBits.Name='Load';
    loadBits.ObjectMethod='onLoadBits';
    loadBits.MethodArgs={'%dialog'};
    loadBits.ArgDataTypes={'handle'};
    loadBits.Alignment=5;
    loadBits.RowSpan=[1,1];
    loadBits.ColSpan=[3,3];


    ipAddressEdit.Type='edit';
    ipAddressEdit.Tag='ipAddressEdit';
    ipAddressEdit.Name='IP Address';
    ipAddressEdit.Value=this.dialogState.IPAddress;
    ipAddressEdit.RowSpan=[2,2];
    ipAddressEdit.ColSpan=[1,1];

    usernameEdit.Type='edit';
    usernameEdit.Tag='usernameEdit';
    usernameEdit.Name='Username';
    usernameEdit.Value=this.dialogState.Username;
    usernameEdit.RowSpan=[3,3];
    usernameEdit.ColSpan=[1,1];

    passwordEdit.Type='edit';
    passwordEdit.Tag='passwordEdit';
    passwordEdit.Name='Password';
    passwordEdit.Value=this.dialogState.Password;
    passwordEdit.RowSpan=[4,4];
    passwordEdit.ColSpan=[1,1];


    loadStatus.Type='text';
    loadStatus.Tag='loadStatus';
    loadStatus.Name=this.dialogState.loadStatus;
    loadStatus.RowSpan=[5,5];
    loadStatus.ColSpan=[1,3];

    if~isempty(this.params.connectionOptions)&&strcmpi(this.params.connectionOptions.Communication_Channel,'PSEthernet')
        lbGroup.Items={bitFileEdit,bitFileBrowse,loadBits,ipAddressEdit,usernameEdit,passwordEdit,loadStatus};
    else
        loadStatus.RowSpan=loadStatus.RowSpan-3;
        lbGroup.Items={bitFileEdit,bitFileBrowse,loadBits,loadStatus};
    end

end


function rtGroup=l_CreateRuntimeOptionsWidget(this)
    rtGroup.Type='group';
    rtGroup.Tag='rtGroup';
    rtGroup.Name='Runtime Options';
    rtGroup.LayoutGrid=[6,4];


    resetFpga.Type='checkbox';
    resetFpga.Tag='resetFpga';
    resetFpga.Name='Reset FPGA at start of simulation';
    resetFpga.Value=this.params.resetFpga;
    resetFpga.RowSpan=[1,1];
    resetFpga.ColSpan=[1,3];
    resetFpga.Visible=0;
    resetFpga=l_AddWidgetChangeCallback(resetFpga);


    resetDut.Type='checkbox';
    resetDut.Tag='resetDut';
    resetDut.Name='Reset DUT at start of simulation';
    resetDut.Value=this.params.resetDut;
    resetDut.RowSpan=[2,2];
    resetDut.ColSpan=[1,3];
    resetDut.Visible=0;
    resetDut=l_AddWidgetChangeCallback(resetDut);

    ocTxt1.Type='text';
    ocTxt1.Tag='ocTxt1';
    ocTxt1.Name=sprintf('Overclocking factor:');
    ocTxt1.ToolTip=sprintf('The overclocking factor is the number of FPGA DUT\nclock periods per input base sample time.');
    ocTxt1.RowSpan=[3,3];
    ocTxt1.ColSpan=[1,1];

    ocCombo=l_Combo('ocCombo',this.params.overclocking.stringCtorList(),this.params.overclocking.asString());
    ocCombo.RowSpan=[3,3];
    ocCombo.ColSpan=[2,2];


    procTxt.Type='text';
    procTxt.Tag='procTxt';
    procTxt.Name='Input and output processing:';
    procTxt.RowSpan=[4,4];
    procTxt.ColSpan=[1,1];
    procTxt.Visible=0;


...
...
...
...
...
...
...
...
...
    procStrVal='Process as frames';
    frameSizeEn=true;
    procCombo.Type='combobox';
    procCombo.Tag='procCombo';
    procCombo.Editable=false;
    procCombo.RowSpan=[4,4];
    procCombo.ColSpan=[2,2];
    procCombo.Entries={'Process as samples',...
    'Process as frames'};
    procCombo.Value=procStrVal;
    procCombo=l_AddWidgetChangeCallback(procCombo);
    procCombo.Visible=0;



    inFSTxt.Type='text';
    inFSTxt.Tag='inFSTxt';
    inFSTxt.Name='Input frame size:';
    inFSTxt.RowSpan=[5,5];
    inFSTxt.ColSpan=[1,1];
    inFSTxt.Visible=0;


    inFSCombo=l_Combo('inFSCombo',this.params.inputFrameSize.stringCtorList(),this.params.inputFrameSize.asString());
    inFSCombo.Enabled=frameSizeEn;
    inFSCombo.RowSpan=[5,5];
    inFSCombo.ColSpan=[2,2];
    inFSCombo.Visible=0;

    outFSTxt.Type='text';
    outFSTxt.Tag='outFSTxt';
    outFSTxt.Name='Output frame size:';
    outFSTxt.RowSpan=[6,6];
    outFSTxt.ColSpan=[1,1];

    outFSCombo=l_Combo('outFSCombo',this.params.outputFrameSize.stringCtorList(),this.params.outputFrameSize.asString());
    outFSCombo.Enabled=frameSizeEn;
    outFSCombo.RowSpan=[6,6];
    outFSCombo.ColSpan=[2,2];

    rtGroup.Items={resetFpga,resetDut,ocTxt1,ocCombo,...
    procTxt,procCombo,inFSTxt,inFSCombo,outFSTxt,outFSCombo};
end

function w=l_Combo(tag,comboList,curVal)
    w.Type='combobox';
    w.Editable=true;
    w.Tag=tag;
    w.Entries=comboList;

    m=strcmp(curVal,comboList);
    i=find(m);
    if(isempty(i))
        val=curVal;
    else
        val=comboList{i};
    end
    w.Value=val;
    w=l_AddWidgetChangeCallback(w);
end


function ptGroup=l_CreatePortTableWidget(this)
    ptGroup.Type='panel';
    ptGroup.Tag='ptGroup';
    ptGroup.LayoutGrid=[1,1];



    ptC.RowSpan=[1,1];
    ptC.ColSpan=[1,1];
    ptC.Alignment=3;
    totalRows=double(1+this.params.getNumInputPorts+this.params.getNumOutputPorts);
    totalCols=6;
    ptC.Type='panel';
    ptC.Tag='ptC';
    ptC.LayoutGrid=[totalRows,totalCols];
    ptC.Items=l_getTableRows(this);

    ptGroup.Items={ptC};

end

function w=l_getTableRows(this)
    rownum=1;
    w=l_getCurRow(rownum,'','');
    rownum=rownum+1;

    for idx=1:this.params.getNumInputPorts
        w=[w,l_getCurRow(rownum,'Input',this.params.inputPorts(idx))];%#ok<AGROW>
        rownum=rownum+1;
    end
    for idx=1:this.params.getNumOutputPorts
        w=[w,l_getCurRow(rownum,'Output',this.params.outputPorts(idx))];%#ok<AGROW>
        rownum=rownum+1;
    end

end
function w=l_getCurRow(row,portDir,pinfo)
    if(row==1)
        hname=l_getTextCell(row,1,'hname','HDL Name');
        dir=l_getTextCell(row,2,'dir','Dir');
        bitw=l_getTextCell(row,3,'bitw',sprintf('Bit\nWidth'));
        stime=l_getTextCell(row,4,'stime',sprintf('Sample\nTime'));
        dtype=l_getTextCell(row,5,'dtype','Data type');
        vphase=l_getTextCell(row,6,'vphase',sprintf('Valid\nPhase'));
        vphase.Visible=0;
    else
        hname=l_getTextCell(row,1,'hname',pinfo.name);
        dir=l_getTextCell(row,2,'dir',portDir);
        bitw=l_getTextCell(row,3,'bitw',num2str(pinfo.elemBitwidth));
        stime=l_getComboCell(row,4,'stime',pinfo.sampleTime.stringCtorList(),pinfo.sampleTime.asString());
        dtype=l_getComboCell(row,5,'dtype',pinfo.dtypeSpec.stringCtorList(),pinfo.dtypeSpec.asString());
        vphase=l_getEditCell(row,6,'vphase',num2str(pinfo.validPhase),portDir);

        if strcmp(portDir,'Input')
            stime.Enabled=0;
            dtype.Enabled=0;
            vphase.Enabled=0;
        end
    end
    w={hname,dir,bitw,stime,dtype,vphase};
end
function w=l_getTextCell(row,col,tag,text)
    w.Type='text';
    w.Tag=[tag,'_r',num2str(row),'c',num2str(col)];
    w.RowSpan=[row,row];
    w.ColSpan=[col,col];
    w.Name=text;
    w.FontFamily='courier';
    if(row==1)
        w.Bold=true;
        w.Alignment=6;
    end
    switch(tag)
    case 'bitw'
        w.Alignment=6;
    end

end
function w=l_getComboCell(row,col,tag,comboList,curVal)
    ttag=[tag,'_r',num2str(row),'c',num2str(col)];
    w=l_Combo(ttag,comboList,curVal);
    w.RowSpan=[row,row];
    w.ColSpan=[col,col];

    switch(tag)
    case 'stime'
        w.ToolTip=sprintf(['A valid sample time expression includes ''[1 0]'', ''1'', \n',...
        'or any other evalable ''[period offset]'' string.']);
    case 'dtype'
        w.ToolTip=sprintf(['A valid data type expression includes any evalable ''fixdt(...)'' \n',...
        'string or DataTypeNameString such as ''sfix8_En3'' as documented for \n',...
        '''fixdt''.']);
    end
end
function w=l_getEditCell(row,col,tag,value,dir)
    w.Type='edit';
    w.Tag=[tag,'_r',num2str(row),'c',num2str(col)];
    w.RowSpan=[row,row];
    w.ColSpan=[col,col];
    w.Value=value;
    w.ToolTip=sprintf(['Choose a valid phase in the range [0, N-1] where N\n',...
    'is the number of FPGA clocks between Simulink sample time hits.']);
    w=l_AddWidgetChangeCallback(w);
    switch(dir)
    case 'Input',w.Visible=0;
    case 'Output',w.Visible=0;
    end
end



