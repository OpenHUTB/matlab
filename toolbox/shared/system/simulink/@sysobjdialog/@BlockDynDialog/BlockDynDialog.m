function this=BlockDynDialog(blockh,varargin)





    this=sysobjdialog.BlockDynDialog(blockh);




    dm=matlab.system.ui.BlockDialogManager.getInstance;



    dm.remove(blockh);
    this.DialogManager=dm.create(blockh);


    this.init(blockh);


