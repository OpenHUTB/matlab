function hNewC=getFilterComp(hN,hC,hFilterImpl)



    if nargin<3
        error(message('hdlcommon:hdlcommon:FilterElaborationML'));
    end

    hF=hC.getFilterObj;
    hNewC=hFilterImpl.baseElaborate(hN,hC);
    hNewC.HDLUserData.FilterObject=hF;
    hFilterImpl.generateClocks(hN,hNewC);
















end
