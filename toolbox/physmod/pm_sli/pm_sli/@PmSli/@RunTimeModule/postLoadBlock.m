function postLoadBlock(this,hBlock)




    ;


    if~this.isLibraryBlock(hBlock)

        this.initializeModelEditingMode(hBlock);
        this.addBlock(hBlock,true);

    end


