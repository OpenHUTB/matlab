function choice=getChoice(this)




    choice='off';

    controlFileParam=this.getImplParams('UseMultiplier');

    if~isempty(controlFileParam)
        choice=controlFileParam;
    end
