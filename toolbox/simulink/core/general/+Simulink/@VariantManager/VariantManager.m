classdef(Sealed)VariantManager


































    methods(Static)

        vars=findVariantControlVars(model,varargin);


        varargout=reduceModel(modelName,varargin);




        status=isVariantReducerActive();




        varargout=activateModel(modelName,varargin);



        varargout=applyConfiguration(modelName,varargin);



        vcdoObj=getConfigurationData(modelName);



        configName=getPreferredConfigurationName(modelName);



        vssHandle=convertToVariant(blockH);


        convertToVariantAssemblySubsystem(vssBlkPath,folderPathToKeepNewSSRefFiles);


        variantLegend(modelName,action,varargin);


        varargout=generateConfigurations(modelName,varargin);
    end

    methods(Static,Hidden)


        vssHandle=convToVarLibWrapper(blockH);
    end

end


