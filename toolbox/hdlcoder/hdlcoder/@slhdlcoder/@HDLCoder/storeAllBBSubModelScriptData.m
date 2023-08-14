function storeAllBBSubModelScriptData(this,Models,blackBoxVHDLLibNames)




    numModels=numel(Models);
    for ii=1:numModels
        mdlName=Models(ii).modelName;
        vhdlLibName=blackBoxVHDLLibNames(mdlName);
        modelCodeGenDir=fullfile(this.hdlGetBaseCodegendir,mdlName);
        fileList='';
        fileList=getHDLFilesForProtectedModel(this,modelCodeGenDir,'v',fileList);
        fileList=getHDLFilesForProtectedModel(this,modelCodeGenDir,'vhd',fileList);
        storeSubProtectedModelScriptData(this,mdlName,modelCodeGenDir,vhdlLibName,fileList);
    end
end
