function setECUPage(this,pageNum)










    this.setCalPage(this.ModeECUOnly,pageNum);

    notify(this,'CalPageChanged');
end
