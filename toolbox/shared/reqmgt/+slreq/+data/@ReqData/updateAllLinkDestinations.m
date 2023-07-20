function changed=updateAllLinkDestinations(this,linkSet,loadReferencedReqsets)





    if nargin<3

        loadReferencedReqsets=true;
    end

    changed=false;

    modelLinkSet=linkSet.getModelObj();
    if~isempty(modelLinkSet)
        changed=this.resolveReferences(modelLinkSet,loadReferencedReqsets);
    end
end
