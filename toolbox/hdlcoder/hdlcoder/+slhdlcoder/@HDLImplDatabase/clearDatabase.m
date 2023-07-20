function clearDatabase(this)








    delete(this.BlockDB);
    this.BlockDB=containers.Map;
    delete(this.DescriptionDB);
    this.DescriptionDB=containers.Map;

    this.ConfigFiles=[];
    this.LibraryDB=[];
