function val=getDisplayLabel(this)




    val='';
    if(isa(this,'DAStudio.Object')||isa(this,'Simulink.DABaseObject'))
        val=this.Name;
    end

end
