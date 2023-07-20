function setButtonState(self,row,val,refresh)





    self.filestate(row)=val;
    if refresh,self.mywindow.restoreFromSchema(true);end