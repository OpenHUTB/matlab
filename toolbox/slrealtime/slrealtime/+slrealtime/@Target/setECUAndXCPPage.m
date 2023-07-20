function setECUAndXCPPage(this,pageNum)











    this.setCalPage(this.ModeECUAndXCP,pageNum);

    notify(this,'CalPageChanged');
end
