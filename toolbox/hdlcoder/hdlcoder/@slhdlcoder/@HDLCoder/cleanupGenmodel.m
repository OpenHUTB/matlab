function cleanupGenmodel(this)




    if~isempty(this.BackEnd)
        mdlFiles={this.BackEnd.OutModelFile,this.BackEnd.TopOutModelFile};
        for ii=1:numel(mdlFiles)
            if~isempty(mdlFiles{ii})&&...
                ~isempty(find_system('type','block_diagram','name',mdlFiles{ii}))&&...
                strcmpi(get_param(mdlFiles{ii},'Shown'),'off')









                set_param(mdlFiles{ii},'Dirty','off');
            end
        end
    end

end