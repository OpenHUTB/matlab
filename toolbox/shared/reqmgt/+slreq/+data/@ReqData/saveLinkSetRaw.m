





function result=saveLinkSetRaw(this,mfLinkSet,asVersion)






    assert(~isempty(mfLinkSet));

    if nargin<3
        asVersion='';
    end

    this.setMATLABVersion(mfLinkSet,asVersion);


    this.maskSelfReferences(mfLinkSet);

    if~isempty(asVersion)




        this.migrateLinkSet(mfLinkSet,asVersion);
    end





    if mfLinkSet.dirty
        mfLinkSet.revision=mfLinkSet.revision+1;
    end



    package=slreq.opc.Package(mfLinkSet.filepath);
    data=this.serialize(mfLinkSet,asVersion);
    package.save(data);

    mfLinkSet.dirty=false;
    result=true;
end
