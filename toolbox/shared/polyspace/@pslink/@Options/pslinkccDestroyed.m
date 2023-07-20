function pslinkccDestroyed(this,unused)%#ok<INUSD>












    tmpObj=this.deepCopy();
    this.pslinkcc=tmpObj.pslinkcc;
    this.pslinkccListeners=[];
