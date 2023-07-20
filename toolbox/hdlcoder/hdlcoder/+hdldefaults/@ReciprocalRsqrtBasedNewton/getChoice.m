function choice=getChoice(this)




    choice=3;

    controlFileParam=this.getImplParams('Iterations');

    if~isempty(controlFileParam)
        choice=controlFileParam;
    end
