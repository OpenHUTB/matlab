function blockInfo=getBlockInfo(this,hC)















    bfp=hC.Simulinkhandle;

    fromPort=strcmp(get_param(bfp,'BlockSizeSource'),'Input port');
    bLen=this.hdlslResolve('BlockSize',bfp);
    numIter=this.hdlslResolve('NumIterations',bfp);
    wSize=32;



    bLen_ext=ceil((bLen)/wSize)*wSize;





    addrWL=13;




    blockInfo.sizefromPort=fromPort;
    blockInfo.blockLen=bLen;
    blockInfo.blockLen_ext=bLen_ext;
    blockInfo.winSize=wSize;
    blockInfo.numIterations=numIter;
    blockInfo.dataRAMaddrType=pir_ufixpt_t(addrWL,0);
    blockInfo.alphaRAMaddrType=pir_ufixpt_t(log2(2*wSize),0);




    insignals=hC.PirInputSignals;
    dataType=insignals(1).Type.BaseType;
    inWL=dataType.WordLength;
    inFL=dataType.FractionLength;
    smetFL=inFL-1;

    extrinType=pir_sfixpt_t(inWL+2,inFL);



    smetType=pir_sfixpt_t(inWL+5,smetFL);





    input_intWL=inWL+inFL-1;
    alpha_intWL=input_intWL+4;

    negLLR=0;
    threshold=2^(input_intWL+2);

    offset=round(2^(alpha_intWL)*0.2);

    inistmet=-round(2^(alpha_intWL)*0.75);

    bound=2^alpha_intWL;


    blockInfo.dataType=dataType;
    blockInfo.dataVType=insignals(1).Type;
    blockInfo.extrinType=extrinType;
    blockInfo.extrinExtType=pir_sfixpt_t(inWL+3,smetFL);
    blockInfo.smetType=smetType;
    blockInfo.negLLR=negLLR;
    blockInfo.threshold=threshold;
    blockInfo.offset=offset;
    blockInfo.inistmet=inistmet;
    blockInfo.bound=bound;




