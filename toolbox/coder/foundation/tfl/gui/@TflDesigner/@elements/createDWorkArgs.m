function createDWorkArgs(this)





    this.object.DWorkArgs=[];
    this.allocatesdwork=false;
    if any(strcmp(this.object.Key,{'RTW_SEM_INIT','RTW_MUTEX_INIT'}))
        arg=this.parentnode.object.getTflDWorkFromString('d1','void*');
        this.object.addDWorkArg(arg);
        this.allocatesdwork=true;


        arg=this.parentnode.object.getTflDWorkFromString('d1','void**');
        this.object.Implementation.addArgument(arg);
    else

        arg=this.parentnode.object.getTflDWorkFromString('d1','void*');
        this.object.Implementation.addArgument(arg);
    end