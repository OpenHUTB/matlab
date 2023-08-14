function wasClosed=doClose(this,forceClose)






    this.listenPWD(false);
    disconnect(this);
    wasClosed=true;
