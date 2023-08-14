function[blockList,modelIdx]=getModelBlockEntries(this,mdl)




    blockList=[];

    modelIdx=this.findModelEntry(mdl);
    howManyModels=length(modelIdx);

    switch howManyModels

    case 1

        blockList=this.modelInfo(modelIdx).blockList;

    case 0

        blockList=initializeBlockList;

    otherwise

        configData=RtmModelRegistry_config;
        pm_error(configData.Error.MultiplyRegisteredModel_templ_msgid,mdl.Name);

    end


