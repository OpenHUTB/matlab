






function newvalue=setMemSecFuncExecute(this,proposedValue)

    if this.versionCompare('1.11.0')<0...
        &&strcmp(this.MemSecFuncSharedUtilSetByExecute,'on')



        this.MemSecFuncSharedUtil=proposedValue;
        this.setPrivate_MemSecFuncByExecute('off');
    end
    newvalue=proposedValue;

