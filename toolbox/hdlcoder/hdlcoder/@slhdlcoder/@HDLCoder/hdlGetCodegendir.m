function codegendir=hdlGetCodegendir(this)

    codegendir=this.hdlGetBaseCodegendir();
    numModels=numel(this.AllModels);
    if numModels>0&&this.mdlIdx~=numModels
        codegendir=fullfile(codegendir,this.AllModels(this.mdlIdx).modelName);
    end
end
