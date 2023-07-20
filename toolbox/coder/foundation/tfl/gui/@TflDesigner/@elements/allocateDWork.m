function allocateDWork(this)




    this.object.DWorkArgs=[];
    this.object.DWorkAllocatorEntry=[];

    arg=this.parentnode.object.getTflDWorkFromString('d1','void*');
    this.object.addDWorkArg(arg);
    this.allocatesdwork=true;

