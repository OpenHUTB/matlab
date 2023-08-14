function y=rfblksis_dialog_open(this)





    myblk=[this.Block.Path,'/',this.Block.Name];
    dialog=rfblksfinddialog(myblk);
    if~isempty(dialog)
        y=false;
    else
        y=true;
    end

