function success=clearModelSnapshot(this,hModel)






    success=true;


    success=(this.clearModelTopologySnapshot(hModel)&&this.clearModelBlocksSnapshot(hModel));


