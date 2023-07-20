function resolveLinkType(this,mfLink)






    if reqmgt('rmiFeature','CppReqData')
        this.repository.resolveLinkType(mfLink);
        return;
    end

    mfLinkType=this.repository.linkTypes{mfLink.typeName};

    if isempty(mfLinkType)



        slreq.internal.addCustomLinkTypeAsUnresolvedType(mfLink.typeName);
    end
end
