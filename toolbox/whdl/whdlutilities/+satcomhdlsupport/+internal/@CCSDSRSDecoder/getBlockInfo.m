function blockInfo=getBlockInfo(this,hC)



    bfp=hC.Simulinkhandle;
    blockInfo.MessageLength=this.hdlslResolve('MessageLength',bfp);
    blockInfo.InterleavingDepth=this.hdlslResolve('InterleavingDepth',bfp);
    blockInfo.NumCorrErrPort=strcmp(get_param(bfp,'NumCorrErrPort'),'on');


end
