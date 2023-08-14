function updateDetails(this)

    specName=this.specification.getName;

    if~strcmp(specName,this.getName)
        this.changeName(specName);
    end
end

