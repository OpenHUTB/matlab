function success=snapshotBlock(this,block)



    snapshot=this.createBlockSnapshot(block);

    success=((~isempty(snapshot))&&this.storeOneSnapshot(block,snapshot));





