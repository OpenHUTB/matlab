function blockInfo=getBlockInfo(this,hC)



    bfp=hC.Simulinkhandle;
    blockInfo.MessageLength=this.hdlslResolve('MessageLength',bfp);
    blockInfo.CodewordLength=this.hdlslResolve('CodewordLength',bfp);
    blockInfo.PrimitivePolynomialSource=get_param(bfp,'PrimitivePolynomialSource');
    blockInfo.PrimitivePolynomial=this.hdlslResolve('PrimitivePolynomial',bfp);


    blockInfo.BSource=get_param(bfp,'BSource');
    blockInfo.B=this.hdlslResolve('B',bfp);
    blockInfo.NumErrorsOutputPort=strcmp(get_param(bfp,'NumErrorsOutputPort'),'on');


end
