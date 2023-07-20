function viewHelp(this)





    if~isa(this.ComponentInstance,this.ClassName)
        this.ComponentInstance=this.makeComponent;
    end

    viewHelp(this.ComponentInstance);