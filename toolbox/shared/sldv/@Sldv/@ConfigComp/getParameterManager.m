function[pmanager]=getParameterManager(this,mdl,configSet)









    if isempty(this.ParameterManager)||...
        (~isempty(this.ParameterManager)&&...
        isempty(this.ParameterManager{1}.HModel)&&~isempty(mdl))












        this.ParameterManager{1}=Sldv.ParameterTuning.Manager(mdl,configSet);
    end

    pmanager=this.ParameterManager{1};


end