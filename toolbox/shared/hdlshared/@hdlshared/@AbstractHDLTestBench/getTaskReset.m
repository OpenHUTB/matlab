function reset=getTaskReset(this,component)


    if isempty(component.ResetName)
        reset=this.ResetName;
    else
        reset=component.ResetName;
    end
