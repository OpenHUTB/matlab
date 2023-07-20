function preferredName=getPreferredArchitectureName(this)



    archNames=this.ArchitectureNames;
    if~isempty(archNames)
        preferredName=archNames{1};
    else
        preferredName=class(this);
    end
end
