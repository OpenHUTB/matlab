function this=AutoTimescaleDialog(productName,dialogTag,msgType,msg,dmsg)





    this=hdllinkddg.AutoTimescaleDialog;




    this.productName=productName;
    this.dialogTag=dialogTag;
    this.msgType=msgType;
    this.msg=msg;
    this.dmsg=dmsg;
    if(isempty(dmsg))
        this.showShowBtn=false;
    else
        this.showShowBtn=true;
    end
    this.dmsgTag='dmsgTag';
    this.showBtnTag='showBtnTag';
    this.hideBtnTag='hideBtnTag';

