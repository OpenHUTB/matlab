function modelH=getModelHandle(cbinfo)




    modelName=SLStudio.Utils.getModelName(cbinfo);
    modelH=get_param(modelName,'Handle');
end
