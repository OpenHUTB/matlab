function result=entityNameExists(this,nname)




    p=this.PirInstance;
    result=any(strcmpi(nname,p.getEntityNames));
end