function deleteStereotypeAttributes(this,reqLink,names)

    if isa(reqLink,'slreq.data.Requirement')||isa(reqLink,'slreq.data.Link')
        mfReqLink=this.getModelObj(reqLink);
    elseif isa(reqLink,'slreq.datamodel.RequirementItem')
        mfReqLink=reqLink;
    else

        return;
    end






    deleteAll=false;
    if nargin==2
        deleteAll=true;
        attrNames={};
    else
        attrNames=names;
        if isa(names,'char')

            attrNames={names};
        end
    end

    allKeys=mfReqLink.customAttributes.keys();
    for i=1:length(allKeys)
        name=allKeys{i};
        if deleteAll||any(strcmp(name,attrNames))
            catt=mfReqLink.customAttributes.getByKey(name);
            if~isempty(catt)
                catt.destroy();
            end
        end
    end
end