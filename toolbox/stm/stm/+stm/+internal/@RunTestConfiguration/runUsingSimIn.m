function bool=runUsingSimIn(this)







    if~isempty(this.RunUsingSimInFlag)
        bool=this.RunUsingSimInFlag;
        return;
    end

    bool=slfeature('STMSimulationInput')>0;

    this.RunUsingSimInFlag=bool;
end
