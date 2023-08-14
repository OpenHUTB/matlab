function[mwItems,extItems]=getReqItems(reqSetName)

    r=slreq.data.ReqData.getInstance;
    reqSet=r.getReqSet(reqSetName);
    [mwItems,extItems]=r.getItems(reqSet);

end

