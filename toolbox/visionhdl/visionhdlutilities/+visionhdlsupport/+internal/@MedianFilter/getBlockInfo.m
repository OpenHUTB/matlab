function blockInfo=getBlockInfo(this,hC)

















    if isa(hC,'hdlcoder.sysobj_comp')

        sysObjHandle=hC.getSysObjImpl;

        NeighborhoodSize=sysObjHandle.NeighborhoodSize;
        if strcmpi(NeighborhoodSize,'3x3')
            NSize=3;
        elseif strcmpi(NeighborhoodSize,'5x5')
            NSize=5;
        else
            NSize=7;
        end


        pmethod=sysObjHandle.PaddingMethod;
        pvalue=sysObjHandle.PaddingValue;
        lbufSize=sysObjHandle.LineBufferSize;


    else
        bfp=hC.Simulinkhandle;

        NeighborhoodSize=get_param(bfp,'NeighborhoodSize');
        if strcmpi(NeighborhoodSize,'3x3')
            NSize=3;
        elseif strcmpi(NeighborhoodSize,'5x5')
            NSize=5;
        else
            NSize=7;
        end


        pmethod=get_param(bfp,'PaddingMethod');
        pvalue=this.hdlslResolve('PaddingValue',bfp);
        lbufSize=this.hdlslResolve('LineBufferSize',bfp);

    end

    blockInfo.NSize=NSize;
    blockInfo.bSize=floor(NSize/2);
    blockInfo.PaddingMethod=pmethod;
    blockInfo.PaddingValue=pvalue;
    blockInfo.LineBufferSize=lbufSize;

