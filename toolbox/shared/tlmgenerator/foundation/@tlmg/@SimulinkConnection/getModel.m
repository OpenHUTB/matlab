function v=getModel(this,v)





    if~isempty(this.modelName)
        v=get_param(this.modelName,'ObjectAPI');
    else



        v=[];
    end
