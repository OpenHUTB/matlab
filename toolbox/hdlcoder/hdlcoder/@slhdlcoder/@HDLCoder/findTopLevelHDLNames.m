function names=findTopLevelHDLNames(this,modelName)







    if nargin<2
        if isempty(this.ModelConnection)
            names={};
            return;
        else
            modelName=this.ModelConnection.ModelName;
        end
    end

    if isempty(modelName)
        names={};
        return;
    end

    blks=find_system(modelName,...
    'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.activePlusStartupVariantSubsystem,...
    'BlockType','SubSystem');
    refs=get_param(blks,'ReferenceBlock');


    if isempty(this.ImplDB)
        this.buildDatabase;
    end


    supLibs=this.ImplDB.getSupportedLibraries;


    names={modelName};
    for ii=1:length(refs)








        if strcmpi(get_param(blks{ii},'BlockType'),'SubSystem')&&...
            ~strcmpi(get_param(blks{ii},'SFBlockType'),'NONE')

        elseif~isempty(refs{ii})
            sllasterror_val=sllasterror;
            [lastwarn_msg,lastwarn_msgid]=lastwarn;
            sllastwarn_val=sllastwarning;
            try
                lib=get_param(refs{ii},'Parent');
            catch me

                sllasterror(sllasterror_val);
                lastwarn(lastwarn_msg,lastwarn_msgid);
                sllastwarning(sllastwarn_val);
                continue;
            end
            if~(strncmp(lib,'simulink/',9)||...
                any(strcmp(lib,supLibs)))
                names{end+1}=blks{ii};%#ok<AGROW>
            end
        elseif~isempty(get_param(blks{ii},'Blocks'))
            names{end+1}=blks{ii};%#ok<AGROW>
        end
    end


    names=hdlfixblockname(names);
end


