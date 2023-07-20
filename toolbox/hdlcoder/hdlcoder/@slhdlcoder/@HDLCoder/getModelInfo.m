function[modelInfo,mdlIdx]=getModelInfo(this,modelName)
    mdlIdx=find(strcmpi({this.AllModels.modelName},modelName),1);
    assert(~isempty(mdlIdx));
    modelInfo=this.AllModels(mdlIdx);
end
