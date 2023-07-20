function v=setWaiveFailure(this,new_val)




    v=new_val;





    if new_val
        this.updateStates('WaivedPass');





    else
        this.updateStates(this.InternalState);
        this.InternalState='';




    end
