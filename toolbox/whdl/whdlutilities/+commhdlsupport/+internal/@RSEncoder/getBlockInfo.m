function blockInfo=getBlockInfo(this,hC)



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
