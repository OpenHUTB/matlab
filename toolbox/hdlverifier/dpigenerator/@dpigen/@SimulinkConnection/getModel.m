function v=getModel(this,~)





    if~isempty(this.ModelName)
        v=get_param(this.ModelName,'ObjectAPI');
    else



        v=[];
    end
