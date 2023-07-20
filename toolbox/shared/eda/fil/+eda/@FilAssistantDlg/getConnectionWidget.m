function[BoardCommInfo,showAdvancedOptions,showIPWidget]=getConnectionWidget(this,boardName)





    hManager=eda.internal.boardmanager.BoardManager.getInstance;
    if strcmp(boardName,this.getCatalogMsgStr('ChooseBoard'))||...
        strcmp(boardName,'Choose a platform')
        Connection{1}.Name='';
        Connection{1}.RTIOStreamLibName='';
    else
        boardObj=hManager.getBoardObj(boardName);
        Connection=boardObj.getFILConnectionOptions;
        if this.ConnectionSelection>numel(Connection)-1||this.ConnectionSelection<0
            this.ConnectionSelection=0;
        end
    end
    showAdvancedOptions=~isempty(Connection{this.ConnectionSelection+1}.RTIOStreamLibName);
    showIPWidget=strcmpi(Connection{this.ConnectionSelection+1}.RTIOStreamLibName,'mwrtiostreamtcpip');


    if isa(Connection{this.ConnectionSelection+1},'eda.internal.boardmanager.RMII')
        this.Status='Warning: Only Vivado 2019.1 or earlier versions support RMII PHY. It is not supported with newer versions.';
        if~this.RMIIDeprecationDlgDisplayed
            warndlg(DAStudio.message('EDALink:boardmanagergui:XilinxRMIIPHYDeprecate'),'RMII PHY deprecation');
            this.RMIIDeprecationDlgDisplayed=true;
        end
    else
        this.Status='';
    end


    this.BuildInfo.setConnection(Connection{this.ConnectionSelection+1});

    BoardCommInfo.Type='combobox';
    BoardCommInfo.Tag='edaBoardCommInfo';
    BoardCommInfo.Name=this.getCatalogMsgStr('BoardCommInfo_Text');
    BoardCommInfo.Entries=cellfun(@(x)x.Name,Connection,'UniformOutput',false);
    BoardCommInfo.Mode=1;
    BoardCommInfo.ObjectProperty='ConnectionSelection';
    BoardCommInfo.Source=this;
    BoardCommInfo.DialogRefresh=true;

    if this.IsInHDLWA
        BoardCommInfo.RowSpan=[1,1];
        BoardCommInfo.ColSpan=[1,1];
    else
        BoardCommInfo.RowSpan=[2,3];
        BoardCommInfo.ColSpan=[2,10];
    end

