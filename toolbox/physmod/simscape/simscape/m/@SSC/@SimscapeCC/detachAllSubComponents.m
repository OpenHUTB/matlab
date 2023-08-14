function detachAllSubComponents(this)




    this.ComponentsAttached=false;

    theComponents=this.Components;
    for j=1:length(theComponents)
        this.detachComponent(theComponents(j).Name);
    end

