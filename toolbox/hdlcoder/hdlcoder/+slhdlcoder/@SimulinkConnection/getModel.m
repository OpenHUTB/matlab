function v=getModel(this,v)






    if~isempty(this.ModelName)
        v=get_param(this.ModelName,'ObjectAPI_FP');
    else



        v=[];
    end
