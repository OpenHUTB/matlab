function rdf=getItemRdfById(this,id)






    queryBase=this.getReqQueryCapability();
    dcterms=oslc.matlab.Constants.DC;
    namespace=['oslc.prefix=dcterms=',urlencode(['<',dcterms,'>'])];
    select='oslc.select=*';
    if isnumeric(id)
        id=num2str(id);
    end
    where=['oslc.where=dcterms:identifier=',id];
    queryUrl=sprintf('%s&%s&%s&%s',queryBase,namespace,select,where);
    rdf=this.get(queryUrl);
end
