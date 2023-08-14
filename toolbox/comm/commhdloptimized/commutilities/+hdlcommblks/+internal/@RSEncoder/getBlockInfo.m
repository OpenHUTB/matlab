function blockInfo=getBlockInfo(this,hC)





    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;
        blockInfo.MessageLength=sysObjHandle.MessageLength;
        blockInfo.CodewordLength=sysObjHandle.CodewordLength;
        blockInfo.PrimitivePolynomialSource=sysObjHandle.PrimitivePolynomialSource;
        blockInfo.PrimitivePolynomial=sysObjHandle.PrimitivePolynomial;
        blockInfo.PuncturePatternSource=sysObjHandle.PuncturePatternSource;
        blockInfo.PuncturePattern=sysObjHandle.PuncturePattern;
        blockInfo.BSource=sysObjHandle.BSource;
        blockInfo.B=sysObjHandle.B;
    else
        bfp=hC.Simulinkhandle;
        blockInfo.MessageLength=this.hdlslResolve('MessageLength',bfp);
        blockInfo.CodewordLength=this.hdlslResolve('CodewordLength',bfp);
        blockInfo.PrimitivePolynomialSource=get_param(bfp,'PrimitivePolynomialSource');
        blockInfo.PrimitivePolynomial=this.hdlslResolve('PrimitivePolynomial',bfp);
        blockInfo.PuncturePatternSource=get_param(bfp,'PuncturePatternSource');
        blockInfo.PuncturePattern=this.hdlslResolve('PuncturePattern',bfp);
        blockInfo.BSource=get_param(bfp,'BSource');
        blockInfo.B=this.hdlslResolve('B',bfp);
    end
