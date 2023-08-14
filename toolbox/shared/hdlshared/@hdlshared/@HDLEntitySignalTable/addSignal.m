function next=addSignal(this,signal)






    next=this.getAndIncrementNextIndex;



    append(this,signal);


    this.Names(signal.Name)=next;

    ph=signal.Port;
    if~isempty(ph)
        this.PortHandles=[this.PortHandles;ph.Handle];
    else
        this.PortHandles=[this.PortHandles;-1];
    end

