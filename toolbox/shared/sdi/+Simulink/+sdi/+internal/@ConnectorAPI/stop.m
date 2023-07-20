function stop(this)
    if~isempty(this.Port)
        removeControllers(this);
        this.Port=[];





    end
end
