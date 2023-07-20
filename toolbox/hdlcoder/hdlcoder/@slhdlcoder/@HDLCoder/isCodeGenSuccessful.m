function result=isCodeGenSuccessful(this)








    result=this.CodeGenSuccessful&&...
    strcmp(this.getStartNodeName,this.LastStartNodeName)&&...
    isa(this.PirInstance,'hdlcoder.pirctx')&&...
    ~isempty(this.PirInstance.Networks);
end


