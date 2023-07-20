function success=storeOneSnapshot(this,hBlock,snapshot)





    try
        this.modelRegistry.storeBlockData(hBlock,snapshot);
        success=true;
    catch
        success=false;
    end



