

function mfReqIf=importReqIFTemplate(this,mf0Xml,mapping)







    adapter=slreq.datamodel.ReqIFAdapter(this.model);




    mfReqIf=adapter.importFromReqIf(mf0Xml,mapping);



    adapter.destroy();
end