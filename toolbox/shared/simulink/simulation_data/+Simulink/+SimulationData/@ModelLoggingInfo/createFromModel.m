function obj=createFromModel(model,varargin)

















































    narginchk(1,inf);
    if~ischar(model)
        DAStudio.error(...
        'Simulink:Logging:MdlLogInfoCreateFromModelInvalidOpts');
    end


    try
        load_system(model);
    catch me
        id='Simulink:Logging:MdlLogInfoGetDefaultsOpenFailure';
        err=MException(id,DAStudio.message(id,model));
        err=err.addCause(me);
        throw(err);
    end


    obj=Simulink.SimulationData.ModelLoggingInfo(model);


    linksOpt='on';
    masksOpt='all';
    variantOpt='ActiveVariants';
    commentOpt='off';
    bRecurse=true;
    bRelativePaths=false;
    val_processed=false;
    for idx=1:length(varargin)



        if val_processed
            val_processed=false;
            continue;
        end


        if idx==length(varargin)
            DAStudio.error(...
            'Simulink:Logging:MdlLogInfoCreateFromModelInvalidOpts');
        else
            val=varargin{idx+1};
        end
        val_processed=true;


        switch(varargin{idx})
        case 'FollowLinks'
            linksOpt=val;
        case 'LookUnderMasks'
            masksOpt=val;
        case 'Variants'
            variantOpt=val;
        case 'IncludeCommented'
            commentOpt=val;
        case 'ReferencedModels'
            bRecurse=strcmpi(val,'on');
            if~bRecurse&&~strcmpi(val,'off')
                DAStudio.error(...
                'Simulink:Logging:MdlLogInfoCreateFromModelInvalidOpts');
            end
        case 'RelativePaths'
            bRelativePaths=strcmpi(val,'on');
            if~bRelativePaths&&~strcmpi(val,'off')
                DAStudio.error(...
                'Simulink:Logging:MdlLogInfoCreateFromModelInvalidOpts');
            end
        otherwise
            DAStudio.error(...
            'Simulink:Logging:MdlLogInfoCreateFromModelInvalidOpts');
        end
    end


    if bRecurse
        try
            if strcmpi(variantOpt,'ActiveVariants')


                mdls=find_mdlrefs(model,...
                'MatchFilter',@Simulink.match.activeVariants,'IncludeCommented',commentOpt);
            elseif strcmpi(variantOpt,'AllVariants')
                mdls=find_mdlrefs(model,'MatchFilter',@Simulink.match.allVariants,'IncludeCommented',commentOpt);
            end
            for idx=1:length(mdls)
                load_system(mdls{idx});
            end
        catch me
            id='Simulink:Logging:MdlLogInfoGetDefaultsOpenFailure';
            err=MException(id,DAStudio.message(id,model));
            err=err.addCause(me);
            throw(err);
        end
    end


    [sigs,err]=...
    Simulink.SimulationData.ModelLoggingInfo.getLoggedSignalsFromMdl(...
    model,...
    Simulink.BlockPath,...
    bRecurse,...
    variantOpt,...
    commentOpt,...
    linksOpt,...
    masksOpt,...
    true,...
    false,...
    false,...
    Simulink.SimulationData.SignalLoggingInfo.empty,...
    [],...
    model,...
    true);


    if~isempty(err)
        throwAsCaller(err(1));
    end




    if bRelativePaths&&bRecurse
        for idx=1:length(sigs)
            path=Simulink.SimulationData.BlockPath(...
            sigs(idx).blockPath_.getBlock(sigs(idx).blockPath_.getLength),...
            sigs(idx).blockPath_.SubPath);
            if isempty(obj.findSignal(path,sigs(idx).outputPortIndex_))
                sigs(idx).BlockPath=path;
                obj.signals_=[obj.signals_,sigs(idx)];
            end
        end
    else
        obj=obj.setSignals_(sigs);
    end




    obj=obj.cacheSSIDs(...
    true,...
    false);
end
