function generateHDLFor(this,block)





    if~ischar(block)

        disp(sprintf('Invalid configuration ''generateHDLFor'' statement in file: %s',this.fileName));
        display(block);
    end

    this.HDLTopLevel=block;
