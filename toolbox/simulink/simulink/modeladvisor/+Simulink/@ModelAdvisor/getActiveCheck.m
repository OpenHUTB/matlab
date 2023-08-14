function[CheckID,CheckSerialNum]=getActiveCheck(this)




    CheckID='';
    CheckSerialNum=0;

    if~isempty(this.ActiveCheck)
        CheckID=this.ActiveCheck.ID;
        CheckSerialNum=this.ActiveCheck.Index;
    end
