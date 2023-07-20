function restoreSimMode(this)
    mdls=[{this.fOriMdl},this.fRefMdls];
    mdlRefBlks=[];
    if~isempty(this.fRefMdls)
        mdlRefBlks={this.fMdlRefs.block};
    end
    for ii=1:length(mdls)
        if isKey(this.fSimModeMap,mdls{ii})
            set_param(mdls{ii},'SimulationMode',this.fSimModeMap(mdls{ii}));
        end
    end
    modifiedMdls=cell(1,0);
    for ii=1:length(mdlRefBlks)
        if isKey(this.fSimModeMap,mdlRefBlks{ii})

            set_param(mdlRefBlks{ii},'SimulationMode',this.fSimModeMap(mdlRefBlks{ii}));
            modifiedMdls=unique([modifiedMdls,bdroot(mdlRefBlks{ii})]);
        end
    end
    for ii=1:length(modifiedMdls)
        model_obj=get_param(modifiedMdls{ii},'Object');
        model_obj.refreshModelBlocks;
        save_system(modifiedMdls{ii},modifiedMdls{ii},'SaveDirtyReferencedModels','on');
    end
    this.fSimModeMap=containers.Map('KeyType','char','ValueType','char');
end
