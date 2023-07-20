function out=getCustomAttributeList(setlist)

    rdata=slreq.data.ReqData.getInstance;
    out={};
    for n=1:length(setlist)



        thisSet=setlist(n).dataModelObj;
        attrRegistry=rdata.getCustomAttributeRegistries(thisSet);
        thisAttrNames=attrRegistry.keys();
        dupAttrs=ismember(thisAttrNames,out);
        out=[out,{thisAttrNames{~dupAttrs}}];%#ok<AGROW> 
    end
end