function instantiateStages=getInstantiateStages(this)











    instantiateStages=false;

    controlFileParam=this.getImplParams('InstantiateStages');

    if~isempty(controlFileParam)
        instantiateStages=strcmpi(controlFileParam,'on');
    end
