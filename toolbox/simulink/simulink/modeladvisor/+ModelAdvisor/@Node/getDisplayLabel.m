function val=getDisplayLabel(this)




    val=this.DisplayName;



    if isa(this.MAObj,'Simulink.ModelAdvisor')&&...
        isa(this.MAObj.R2FStart,'ModelAdvisor.Procedure')&&...
        isa(this.MAObj.R2FStop,'ModelAdvisor.Node')&&...
        strcmp(this.MAObj.R2FStart.ID,this.ID)
        val=['->>> ',val];
    end




