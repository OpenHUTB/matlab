



function setSimMode2Normal(this)
    mdls=[{this.fOriMdl},this.fRefMdls];

    mdlRefBlks=[];
    if~isempty(this.fRefMdls)
        mdlRefBlks={this.fMdlRefs.block};
    end

    for ii=1:length(mdlRefBlks)
        if~strcmpi(get_param(mdlRefBlks{ii},'SimulationMode'),'normal')
            refMdl=get_param(mdlRefBlks{ii},'ModelName');
            [~,MESSAGE,~]=fileattrib(which(refMdl));
            if MESSAGE.UserWrite==0
                DAStudio.error('sl_pir_cpp:creator:UnwriteableRefModelUnsupportedSimulationMode',getfullname(refMdl),mdlRefBlks{ii});
            end
            linkedBlk=get_param(mdlRefBlks{ii},'ReferenceBlock');
            if~isempty(linkedBlk)
                libMdl=bdroot(linkedBlk);
                if strcmpi(get_param(libMdl,'lock'),'on')
                    DAStudio.error('sl_pir_cpp:creator:UnwriteableLibraryUnsupportedSimulationMode',mdlRefBlks{ii},getfullname(libMdl));
                end
            end
            rootMdl=bdroot(mdlRefBlks{ii});
            if strcmpi(get_param(rootMdl,'BlockDiagramType'),'library')&&strcmpi(get_param(rootMdl,'lock'),'on')
                DAStudio.error('sl_pir_cpp:creator:UnwriteableLibraryUnsupportedSimulationMode',mdlRefBlks{ii},getfullname(rootMdl));
            end
        end
    end

    for ii=1:length(mdls)
        if~strcmpi(get_param(mdls{ii},'SimulationMode'),'normal')
            if ii==1
                [~,MESSAGE,~]=fileattrib(which(mdls{ii}));
                if MESSAGE.UserWrite==0
                    DAStudio.error('sl_pir_cpp:creator:UnwriteableModelUnsupportedSimulationMode',getfullname(mdls{ii}));
                end
            end
            this.fSimModeMap(mdls{ii})=get_param(mdls{ii},'SimulationMode');
            set_param(mdls{ii},'SimulationMode','normal');
        end
    end

    for ii=1:length(mdlRefBlks)
        if~strcmpi(get_param(mdlRefBlks{ii},'SimulationMode'),'normal')
            this.fSimModeMap(mdlRefBlks{ii})=get_param(mdlRefBlks{ii},'SimulationMode');
            set_param(mdlRefBlks{ii},'SimulationMode','normal');
        end
    end
end
