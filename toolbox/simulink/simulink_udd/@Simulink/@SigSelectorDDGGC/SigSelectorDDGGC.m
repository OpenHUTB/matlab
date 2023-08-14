function this=SigSelectorDDGGC(tcpeer)








    this=Simulink.SigSelectorDDGGC;
    this.TCPeer=tcpeer;
    opts=tcpeer.getOptions;
    hidebusroot=opts.HideBusRoot;
    cb=@(h,ev)update(this,h,ev);
    M(1)=addlistener(tcpeer,'ComponentChanged',cb);
    M(2)=addlistener(tcpeer,'ObjectBeingDestroyed',@(x,y)delete(this));
    M(3)=addlistener(tcpeer,'ItemsChanged',@(es,ed)updateItems(this,hidebusroot,es));
    updateItems(this,hidebusroot,this.TCPeer);
    this.TCListeners=M;




