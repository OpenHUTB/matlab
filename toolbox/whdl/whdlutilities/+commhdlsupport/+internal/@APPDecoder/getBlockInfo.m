function blockInfo=getBlockInfo(this,hC)




    bfp=hC.Simulinkhandle;
    blockInfo.WindowLength=this.hdlslResolve('WindowLength',bfp);
    blockInfo.CodeGenerator=this.hdlslResolve('CodeGenerator',bfp);
    blockInfo.TermMode=get_param(bfp,'TermMode');
    blockInfo.Algorithm=get_param(bfp,'Algorithm');
    blockInfo.DisableAprOut=get_param(bfp,'DisableAprOut');


    K=size(dec2bin(oct2dec(blockInfo.CodeGenerator)),2);
    trellis=poly2trellis(K,blockInfo.CodeGenerator);
    blockInfo.bit0indices=oct2dec(trellis.outputs(:,1))+1;
    blockInfo.bit1indices=oct2dec(trellis.outputs(:,2))+1;
    n=size(dec2bin(oct2dec(trellis.outputs)),2);
    blockInfo.bitIndicesCoded=logical(reshape(int2bit(oct2dec(trellis.outputs),n),n,[])');
    blockInfo.alphaSize=2^(K-1);
    blockInfo.ConstrLen=K;
    x=fi((log(1+exp(-[0:(1/16):8]))),0,16,16,hdlfimath);



    tpinfo=pirgetdatatypeinfo(hC.PirInputSignals(1).Type);
    blockInfo.wordSize=tpinfo.wordsize;
    blockInfo.fracSize=tpinfo.binarypoint;
    blockInfo.vecSize=double(tpinfo.dims);

    bitgrowth=floor(log2(blockInfo.vecSize))+2+floor(log2(K-1));
    blockInfo.logMAPLUT=fi(x(1:end-1),1,blockInfo.wordSize+bitgrowth,-blockInfo.fracSize,hdlfimath);
end
