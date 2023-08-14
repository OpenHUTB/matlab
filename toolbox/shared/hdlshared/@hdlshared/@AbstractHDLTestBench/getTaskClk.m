function clk=getTaskClk(this,component)


    if isempty(component.ClockName)
        clk=this.ClockName;
    else
        clk=component.ClockName;
    end
