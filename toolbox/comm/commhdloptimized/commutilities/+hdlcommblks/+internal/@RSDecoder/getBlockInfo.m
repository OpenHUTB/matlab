function blockInfo=getBlockInfo(this,hC)





    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;
        blockInfo.MessageLength=sysObjHandle.MessageLength;
        blockInfo.CodewordLength=sysObjHandle.CodewordLength;
        blockInfo.PrimitivePolynomialSource=sysObjHandle.PrimitivePolynomialSource;
        blockInfo.PrimitivePolynomial=sysObjHandle.PrimitivePolynomial;


        blockInfo.BSource=sysObjHandle.BSource;
        blockInfo.B=sysObjHandle.B;
        blockInfo.NumErrorsOutputPort=sysObjHandle.NumErrorsOutputPort;
    else
        bfp=hC.Simulinkhandle;
        blockInfo.MessageLength=this.hdlslResolve('MessageLength',bfp);
        blockInfo.CodewordLength=this.hdlslResolve('CodewordLength',bfp);
        blockInfo.PrimitivePolynomialSource=get_param(bfp,'PrimitivePolynomialSource');
        blockInfo.PrimitivePolynomial=this.hdlslResolve('PrimitivePolynomial',bfp);


        blockInfo.BSource=get_param(bfp,'BSource');
        blockInfo.B=this.hdlslResolve('B',bfp);
        blockInfo.NumErrorsOutputPort=strcmp(get_param(bfp,'NumErrorsOutputPort'),'on');
    end
