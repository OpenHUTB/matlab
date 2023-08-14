function storeBlockData(this,block,data,mdl)








    if nargin<4
        mdl=[];
    end

    [oldData,whichModelEntry,mdl]=this.getBlockData(block,mdl);

    if isempty(whichModelEntry)


        if isempty(mdl)
            mdlName='(none)';
        else
            mdlName=mdl.Name;
        end

        configData=RtmModelRegistry_config;

        pm_error(configData.Error.ModelNotRegistered_templ_msgid,mdlName);

    end


    if~isempty(oldData)

        configData=RtmModelRegistry_config;
        pm_error(configData.Error.BlockDataExists_templ_msgid,pmsl_sanitizename(block.Name));

    end


    this.modelInfo(whichModelEntry).blockList(end+1).block=block;
    this.modelInfo(whichModelEntry).blockList(end).data=data;


