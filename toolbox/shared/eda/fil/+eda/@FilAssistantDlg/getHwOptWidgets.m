function WidgetGroup=getHwOptWidgets(this)








    ToolSel.Type='radiobutton';
    ToolSel.Tag='edaToolSelection';
    ToolSel.Name=this.getCatalogMsgStr('Tool_Text');
    ToolSel.Entries=this.BuildInfo.ToolList;
    ToolSel.RowSpan=[1,1];
    ToolSel.ColSpan=[1,2];
    ToolSel.Mode=1;
    ToolSel.ObjectProperty='Tool';

    BoardTxt.Type='text';
    BoardTxt.Tag='edaBoardTxt';
    BoardTxt.Name='Board Name:';
    BoardTxt.RowSpan=[1,1];
    BoardTxt.ColSpan=[1,2];

    hManager=eda.internal.boardmanager.BoardManager.getInstance;
    BoardSel.Type='combobox';
    BoardSel.Tag='edaBoardSelection';
    BoardSel.Entries=[...
    this.getCatalogMsgStr('ChooseBoard');...
    hManager.getFILBoardNamesByVendor('All')';...
    this.getCatalogMsgStr('GetMoreBoards');...
    this.getCatalogMsgStr('CreateNewBoard')];
    BoardSel.RowSpan=[1,1];
    BoardSel.ColSpan=[3,10];
    BoardSel.Mode=1;
    BoardSel.ObjectProperty='Board';
    BoardSel.ObjectMethod='onBoardChange';
    BoardSel.MethodArgs={'%dialog'};
    BoardSel.ArgDataTypes={'handle'};


    if this.BuildInfo.ContainsPrefDirSettings
        this.Board=this.BuildInfo.Board;
    end



    if(~any(strcmpi(this.Board,BoardSel.Entries)))
        this.Board=BoardSel.Entries{1};
    end


    if strcmp(this.Board,this.getCatalogMsgStr('GetMoreBoards'))||...
        strcmp(this.Board,this.getCatalogMsgStr('CreateNewBoard'))
        this.Board=BoardSel.Entries{1};
    elseif~strcmp(this.Board,this.getCatalogMsgStr('ChooseBoard'))

        if~this.BuildInfo.ContainsPrefDirSettings
            this.BuildInfo.Board=this.Board;
        else

            ConnectionsAvailable=hManager.getBoardObj(this.Board).getFILConnectionOptions;
            FILConnection=cellfun(@(x)x.Name,ConnectionsAvailable,'UniformOutput',false);
            TempInterfaceIdx=find(strcmp(this.BuildInfo.BoardObj.ConnectionOptions.Name,...
            FILConnection));
            this.ConnectionSelection=TempInterfaceIdx-1;


            this.BuildInfo.ContainsPrefDirSettings=false;
        end
        this.FPGASystemClockFrequency=strtok(this.BuildInfo.FPGASystemClockFrequency,'MHz');
    end

    BoardManagerBtn.Type='pushbutton';
    BoardManagerBtn.Name='Launch Board Manager';
    BoardManagerBtn.Tag='edaLaunchBoardManager';
    BoardManagerBtn.ObjectMethod='onLaunchBoardManager';
    BoardManagerBtn.MethodArgs={'%dialog'};
    BoardManagerBtn.ArgDataTypes={'handle'};
    BoardManagerBtn.RowSpan=[1,1];
    BoardManagerBtn.ColSpan=[11,15];

    BoardDevInfo.Type='text';
    BoardDevInfo.Tag='edaBoardDevInfo';
    if~strcmp(this.Board,this.getCatalogMsgStr('ChooseBoard'))
        BoardDevInfo.Name=this.getCatalogMsgStr('BoardDevInfo_Text',this.BuildInfo.FPGAPartInfo);
    else
        BoardDevInfo.Name='';
    end
    BoardDevInfo.RowSpan=[2,2];
    BoardDevInfo.ColSpan=[2,14];


    [BoardCommInfo,showAdvancedOptions,showIPWidget]=getConnectionWidget(this,this.Board);

    BoardInfoPanel.Type='panel';
    BoardInfoPanel.Tag='edaBoardInfoPanel';
    BoardInfoPanel.RowSpan=[1,4];
    BoardInfoPanel.ColSpan=[1,3];
    BoardInfoPanel.LayoutGrid=[4,15];
    BoardInfoPanel.Items={BoardTxt,BoardSel,BoardManagerBtn,BoardDevInfo,BoardCommInfo};

    IpAddrTxt.Type='text';
    IpAddrTxt.Tag='edaIpAddrTxt';
    IpAddrTxt.Name=this.getCatalogMsgStr('IpAddr_Text');
    IpAddrTxt.RowSpan=[1,1];
    IpAddrTxt.ColSpan=[1,1];
    IpAddrWidget=l_getIpAddrWidget;

    MacAddrTxt.Type='text';
    MacAddrTxt.Tag='edaMacAddrTxt';
    MacAddrTxt.Name=this.getCatalogMsgStr('MacAddr_Text');
    MacAddrTxt.RowSpan=[2,2];
    MacAddrTxt.ColSpan=[1,1];
    MacAddrWidget=l_getMacAddrWidget;

    FPGASystemClockFrequencyTxt.Type='text';
    FPGASystemClockFrequencyTxt.Tag='edaDUTFreqTxt';
    FPGASystemClockFrequencyTxt.Name=this.getCatalogMsgStr('FPGASystemClockFrequency_Text');
    FPGASystemClockFrequencyTxt.RowSpan=[3,3];
    FPGASystemClockFrequencyTxt.ColSpan=[1,1];
    FPGASystemClockFrequencyWidget=l_getFPGASystemClockFrequencyWidget;

    AddressPanel.Type='togglepanel';
    AddressPanel.Tag='edaAddressPanel';
    AddressPanel.Name=this.getCatalogMsgStr('Address_TogglePanel');
    AddressPanel.Alignment=2;
    AddressPanel.RowSpan=[5,8];
    AddressPanel.ColSpan=[1,3];
    AddressPanel.LayoutGrid=[3,2];
    AddressPanel.RowStretch=ones(1,3);
    AddressPanel.ColStretch=[0.5,1];
    if showIPWidget




        EnableHWBufferWidget=this.getEnableHWBufferWidget;

        AddressPanel.Items={...
        IpAddrTxt,IpAddrWidget,...
        MacAddrTxt,MacAddrWidget,...
        FPGASystemClockFrequencyTxt,FPGASystemClockFrequencyWidget,EnableHWBufferWidget};
    else

        FPGASystemClockFrequencyWidget.RowSpan=[1,1];
        FPGASystemClockFrequencyTxt.RowSpan=[1,1];
        FPGASystemClockFrequencyWidget.ColStretch=[4,10];
        AddressPanel.Items={...
        FPGASystemClockFrequencyTxt,FPGASystemClockFrequencyWidget};
    end

    AddressPanel.Visible=showAdvancedOptions;


    HWOptionGroup.Type='group';
    HWOptionGroup.Tag='edaHwOptionGroup';
    HWOptionGroup.Name=this.getCatalogMsgStr('Hw_OptionGroup');
    HWOptionGroup.RowSpan=[2,10];
    HWOptionGroup.ColSpan=[1,1];
    HWOptionGroup.LayoutGrid=[8,3];
    HWOptionGroup.RowStretch=ones(1,8);
    HWOptionGroup.ColStretch=ones(1,3);
    HWOptionGroup.Items={BoardInfoPanel};
    HWOptionGroup.Items{end+1}=AddressPanel;



    WidgetGroup=this.getWidgetGroup;
    WidgetGroup.Tag='edaWidgetGroupHwOpt';
    WidgetGroup.LayoutGrid=[10,1];
    WidgetGroup.RowStretch=ones(1,10);
    WidgetGroup.ColStretch=ones(1,1);
    WidgetGroup.Items={ToolSel,...
    HWOptionGroup};
end

function IpAddrWidget=l_getIpAddrWidget
    IpAddrByte=cell(1,4);
    Dot=cell(1,3);
    NumCols=11;
    ColSpan=1;
    ColStretch=ones(1,NumCols);
    pf=tdkfpgacc.getpixunit;
    for m=1:4
        IpAddrByte{m}.Type='edit';
        IpAddrByte{m}.RowSpan=[1,1];
        IpAddrByte{m}.ColSpan=[ColSpan,ColSpan];
        IpAddrByte{m}.Mode=1;
        IpAddrByte{m}.ObjectProperty=['IpAddrByte',num2str(m)];

        IpAddrByte{m}.MaximumSize=[55,50]*pf;
        IpAddrByte{m}.Tag=['edaIpAddrByte',num2str(m)];
        ColSpan=ColSpan+1;
        if(m~=4)
            Dot{m}.Type='text';
            Dot{m}.Tag=['edaIpDotTxt',num2str(m)];
            Dot{m}.Name='.';
            Dot{m}.FontPointSize=8;
            Dot{m}.RowSpan=[1,1];
            Dot{m}.ColSpan=[ColSpan,ColSpan]*pf;
            Dot{m}.MaximumSize=[15,15]*pf;
            ColStretch(ColSpan)=0;
            ColSpan=ColSpan+1;
        end
    end

    IpAddrWidget.Type='panel';
    IpAddrWidget.Tag='edaIpAddrPanel';
    IpAddrWidget.RowSpan=[1,1];
    IpAddrWidget.ColSpan=[2,2];
    IpAddrWidget.LayoutGrid=[1,NumCols];
    IpAddrWidget.ColStretch=ColStretch;
    IpAddrWidget.Items=[IpAddrByte,Dot];
end

function MacAddrWidget=l_getMacAddrWidget
    MacAddrByte=cell(1,6);
    Dash=cell(1,1);
    ColSpan=1;
    NumCols=14;
    ColStretch=ones(1,NumCols);
    pf=tdkfpgacc.getpixunit;
    for m=1:6
        MacAddrByte{m}.Type='edit';
        MacAddrByte{m}.RowSpan=[1,1];
        MacAddrByte{m}.ColSpan=[ColSpan,ColSpan];
        MacAddrByte{m}.Mode=1;
        MacAddrByte{m}.ObjectProperty=['MacAddrByte',num2str(m)];
        MacAddrByte{m}.MaximumSize=[55,50]*pf;
        MacAddrByte{m}.Tag=['edaMacAddrByte',num2str(m)];
        ColStretch(ColSpan)=1;
        ColSpan=ColSpan+1;
        if(m~=6)
            Dash{m}.Type='text';
            Dash{m}.Tag=['edaMacDashTxt',num2str(m)];
            Dash{m}.Name='-';
            Dash{m}.FontPointSize=8;
            Dash{m}.RowSpan=[1,1];
            Dash{m}.ColSpan=[ColSpan,ColSpan];
            Dash{m}.MaximumSize=[15,15]*pf;
            ColStretch(ColSpan)=0;
            ColSpan=ColSpan+1;
        end
    end

    MacAddrWidget.Type='panel';
    MacAddrWidget.Tag='edaMacAddrPanel';
    MacAddrWidget.RowSpan=[2,2];
    MacAddrWidget.ColSpan=[2,2];
    MacAddrWidget.LayoutGrid=[1,NumCols];
    MacAddrWidget.ColStretch=ColStretch;
    MacAddrWidget.RowStretch=ones(1,1);
    MacAddrWidget.Items=[MacAddrByte,Dash];
end

function FPGASystemClockFrequencyWidget=l_getFPGASystemClockFrequencyWidget

    FrequenctTxtBox.Type='edit';
    FrequenctTxtBox.RowSpan=[1,1];
    FrequenctTxtBox.ColSpan=[1,1];
    FrequenctTxtBox.Mode=1;
    FrequenctTxtBox.ObjectProperty='FPGASystemClockFrequency';


    FrequenctTxtBox.Tag='FPGASystemClockFrequency';

    FPGASystemClockFrequencyWidget.Type='panel';
    FPGASystemClockFrequencyWidget.Tag='edaDUTFreqPanel';
    FPGASystemClockFrequencyWidget.LayoutGrid=[1,2];
    FPGASystemClockFrequencyWidget.RowSpan=[3,3];
    FPGASystemClockFrequencyWidget.ColSpan=[2,2];
    FPGASystemClockFrequencyWidget.ColStretch=[1,10];
    FPGASystemClockFrequencyWidget.Items={FrequenctTxtBox};
end
