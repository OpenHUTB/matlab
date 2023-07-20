function clients=getAlignedObservers(this)



    Simulink.HMI.DatabaseStreaming.removeModelFromActiveSimList(this.Model);
    clients=Simulink.AsyncQueue.Queue.getAlignedObservers(this);
end
