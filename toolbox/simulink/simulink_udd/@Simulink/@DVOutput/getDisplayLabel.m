function val=getDisplayLabel(this)






    mdlObj=this.getParent;
    if isa(mdlObj,'Simulink.BlockDiagram')
        if~strcmp(this.ModelName,mdlObj.Name)
            this.refresh;
        end
    end

    val='Simulink Design Verifier results';






















