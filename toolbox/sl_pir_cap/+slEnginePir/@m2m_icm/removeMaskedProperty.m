function removeMaskedProperty(this,aBlkType,aProperty)



    if isKey(this.fMaskedProperties,aBlkType)
        if isempty(aProperty)
            this.fMaskedProperties.remove(aBlkType);
        else
            idx=find(strcmpi(aProperty,this.fMaskProperties(aBlkType)),1);
            if~isempty(idx)
                properties=this.fMaskProperties(aBlkType);
                properties(idx)=[];
                this.fMaskProperties(aBlkType)=properties;
            end
        end
    end
end
