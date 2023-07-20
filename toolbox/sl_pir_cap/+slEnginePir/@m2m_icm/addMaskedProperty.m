function addMaskedProperty(this,aBlkType,aProperty)



    if isKey(this.fMaskedProperties,aBlkType)
        if isempty(find(strcmpi(aProperty,this.fMaskedProperties(aBlkType)),1))
            this.fMaskedProperties(aBlkType)=[this.fMaskedProperties(aBlkType),aProperty];
        end
    else
        this.fMaskedProperties(aBlkType)={aProperty};
    end
end
