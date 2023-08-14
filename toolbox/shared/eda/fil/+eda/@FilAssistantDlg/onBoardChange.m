function onBoardChange(this,dlg)



    if strcmp(this.Board,this.getCatalogMsgStr('CreateNewBoard'))
        h=boardmanagergui.NewBoardWizard(dlg);
        DAStudio.Dialog(h);
    elseif strcmp(this.Board,this.getCatalogMsgStr('GetMoreBoards'))
        eda.internal.boardmanager.updateBoardList(dlg);
        matlab.addons.supportpackage.internal.explorer.showSupportPackages({'HDLCVXILINX','HDLVALTERA','MICROSEMI'},'tripwire');
    end

    dlg.refresh;

