function[mexCompInfo,toolchainInfo]=getCompilerForModel(model,varargin)















    allowLcc=true;
    lDefaultCompInfo=coder.internal.DefaultCompInfo.createDefaultCompInfo;
    lModelCompInfo=coder.internal.ModelCompInfo.createModelCompInfo...
    (model,lDefaultCompInfo.DefaultMexCompInfo,allowLcc);
    mexCompInfo=lModelCompInfo.ModelMexCompInfo;
    toolchainInfo=lModelCompInfo.ToolchainInfo;
